# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Exit
}

# Function to get VHDX file path from registry
function Get-DefaultVHDXPath {
    $vhdxPath = (Get-ChildItem -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss | 
        Where-Object {$_.GetValue('DistributionName') -eq 'Ubuntu'}).GetValue('BasePath') + '\ext4.vhdx'
    
    if (-not (Test-Path $vhdxPath)) {
        Write-Host "Default VHDX file not found at the expected location: $vhdxPath"
        return $null
    }
    
    return $vhdxPath
}

# Function to get file details
function Get-FileDetails {
    param (
        [string]$FilePath
    )
    $file = Get-Item $FilePath
    return @{
        Name = $file.Name
        Directory = $file.Directory.FullName
        Size = $file.Length
    }
}

# Function to get VHDX path from user
function Get-VHDXPathFromUser {
    $defaultVHDXPath = Get-DefaultVHDXPath

    if ($defaultVHDXPath) {
        Write-Host "Default VHDX file found: $defaultVHDXPath"
        $userInput = Read-Host "Press Enter to use the default path, or input a custom path (q/exit/quit to quit)"
        
        if ($userInput -in @('q', 'exit', 'quit')) {
            return "quit"
        } elseif ([string]::IsNullOrWhiteSpace($userInput)) {
            return $defaultVHDXPath
        } else {
            $userPath = $userInput
        }
    } else {
        $userPath = Read-Host "Please enter the path to the VHDX file or its containing folder (q/exit/quit to quit)"
        if ($userPath -in @('q', 'exit', 'quit')) {
            return "quit"
        }
    }

    # Check if the path is a directory
    if (Test-Path $userPath -PathType Container) {
        $vhdxPath = Join-Path $userPath "ext4.vhdx"
    } else {
        $vhdxPath = $userPath
    }

    # Verify the VHDX file exists
    if (-not (Test-Path $vhdxPath)) {
        Write-Host "VHDX file not found at the specified location: $vhdxPath"
        return $null
    }

    return $vhdxPath
}

# Function to read and display new lines from the file
function Show-NewContent {
    param (
        [string]$FilePath,
        [ref]$LastPosition
    )
    
    if (Test-Path $FilePath) {
        $content = Get-Content $FilePath -Raw
        if ($content.Length -gt $LastPosition.Value) {
            $newContent = $content.Substring($LastPosition.Value)
            Write-Host $newContent -NoNewline
            $LastPosition.Value = $content.Length
        }
    }
}

# Main script logic
do {
    $VHDXPath = Get-VHDXPathFromUser

    if ($VHDXPath -eq "quit") {
        Write-Host "Exiting script."
        exit
    }

    if ($null -eq $VHDXPath) {
        continue
    }

    # Get file details before compression
    $fileDetailsBefore = Get-FileDetails $VHDXPath
    Write-Host "`nVHDX File Details:"
    Write-Host "Name: $($fileDetailsBefore.Name)"
    Write-Host "Directory: $($fileDetailsBefore.Directory)"
    Write-Host "Size before compression: $([math]::Round($fileDetailsBefore.Size / 1GB, 2)) GB"

    # Warn about WSL shutdown
    Write-Host "`nWarning: WSL will be shut down to compact the VHDX file."
    $Confirm = Read-Host "Do you want to continue? (Y/n)"

    if ($Confirm -eq "" -or $Confirm -eq "Y" -or $Confirm -eq "y") {
        # Shut down WSL
        Write-Host "Shutting down WSL..."
        wsl --shutdown

        # Create a temporary diskpart script
        $tempScript = [System.IO.Path]::GetTempFileName()
        @"
select vdisk file="$VHDXPath"
attach vdisk readonly
compact vdisk
detach vdisk
exit
"@ | Set-Content $tempScript

        # Create a temporary file for output
        $outputFile = [System.IO.Path]::GetTempFileName()

        # Run diskpart with the script and redirect output to file
        Write-Host "Running diskpart to compact the VHDX file. This may take a while..."
        $process = Start-Process -FilePath "diskpart.exe" -ArgumentList "/s `"$tempScript`"" -RedirectStandardOutput $outputFile -NoNewWindow -PassThru

        # Display output in real-time
        $lastPosition = 0
        while (!$process.HasExited) {
            Show-NewContent -FilePath $outputFile -LastPosition ([ref]$lastPosition)
            Start-Sleep -Milliseconds 100
        }

        # Display any remaining output
        Show-NewContent -FilePath $outputFile -LastPosition ([ref]$lastPosition)

        # Check if the operation was successful
        $diskpartOutput = Get-Content $outputFile -Raw
        if ($diskpartOutput -match "DiskPart.*compact.*vdisk") {
            Write-Host "`nVHDX file compacted successfully."
        } else {
            Write-Host "`nWarning: VHDX file might not have been compacted successfully. Please check the output above."
        }

        # Get file details after compression
        $fileDetailsAfter = Get-FileDetails $VHDXPath
        $sizeBefore = $fileDetailsBefore.Size
        $sizeAfter = $fileDetailsAfter.Size
        $sizeDifference = $sizeBefore - $sizeAfter
        $percentReduction = [math]::Round(($sizeDifference / $sizeBefore) * 100, 2)

        Write-Host "`nCompression Results:"
        Write-Host "Size before compression: $([math]::Round($sizeBefore / 1GB, 2)) GB"
        Write-Host "Size after compression:  $([math]::Round($sizeAfter / 1GB, 2)) GB"
        Write-Host "Space saved:             $([math]::Round($sizeDifference / 1GB, 2)) GB"
        Write-Host "Percent reduction:       $percentReduction%"

        # Clean up
        Remove-Item $tempScript
        Remove-Item $outputFile

        break
    } else {
        Write-Host "Operation cancelled. Returning to path input."
    }
} while ($true)

Write-Host "`nOperation completed. Press any key to exit."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")