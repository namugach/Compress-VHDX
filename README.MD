# WSL VHDX 파일 압축 도구

이 도구는 Windows Subsystem for Linux (WSL)에서 사용하는 VHDX 파일을 압축하여 디스크 공간을 절약합니다.

## 시스템 요구사항

- Windows 10 또는 Windows 11
- WSL(Windows Subsystem for Linux) 설치
- 관리자 권한

## 설치 및 사용 방법

1. 'Compress-VHDX.ps1'과 'Run-Compress-VHDX.bat' 파일을 같은 폴더에 다운로드합니다.

2. 'Run-Compress-VHDX.bat' 파일 실행 (두 가지 방법):

방법 1: 일반 실행
- 'Run-Compress-VHDX.bat' 파일을 더블클릭합니다.
- PowerShell이 관리자 권한을 요청하면 '예'를 클릭합니다.

방법 2: 직접 관리자 권한으로 실행
- 'Run-Compress-VHDX.bat' 파일을 우클릭하고 "관리자 권한으로 실행"을 선택합니다.

3. VHDX 파일 선택:
- 기본 Ubuntu VHDX 파일을 사용하려면 엔터를 누릅니다.
- 다른 VHDX 파일을 사용하려면 전체 경로를 입력합니다.
  - `C:\wsl\path`
  - `C:\wsl\path\ext4.vhdx`
- 프로그램을 종료하려면 'q', 'exit', 또는 'quit'을 입력합니다.

4. 파일 정보를 확인하고 계속할지 선택합니다:
- 계속하려면 'Y' 또는 엔터를 누릅니다.
- 취소하려면 'N'을 입력합니다.

5. 압축 과정이 실시간으로 표시됩니다.

6. 압축 완료 후 결과를 확인합니다:
- 압축 전후 크기
- 절약된 공간
- 압축률

7. 아무 키나 눌러 프로그램을 종료합니다.

## 주요 기능

- 기본 Ubuntu VHDX 파일 자동 감지
- 사용자 지정 VHDX 파일 경로 입력 지원
- 실시간 압축 진행 상황 표시
- 상세한 압축 결과 제공

## 주의사항

- 프로그램 실행 시 WSL이 자동으로 종료됩니다. 열린 WSL 세션의 작업을 먼저 저장하세요.
- 관리자 권한이 필요합니다. 일반 실행 시 자동으로 관리자 권한을 요청합니다.
- 이미 최적화된 VHDX 파일은 추가 압축이 이루어지지 않을 수 있습니다.

## 문제 해결

- 경로 입력 오류: 전체 경로를 정확히 입력했는지 확인하세요. 
예: `C:\Users\YourName\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu_79rhkp1fndgsc\LocalState\ext4.vhdx`
- 권한 오류: 관리자 권한으로 실행했는지 확인하세요. 자동 요청에 '예'를 선택했는지 확인하세요.
- 압축 실패: 디스크 공간이 충분한지, VHDX 파일이 사용 중이 아닌지 확인하세요.

## 팁

- WSL 배포판별 VHDX 파일 위치는 다를 수 있습니다. 정확한 경로를 모르는 경우, 
Windows 탐색기에서 `%LOCALAPPDATA%\Packages`를 검색하여 찾아보세요.
- 정기적으로 VHDX 파일을 압축하면 디스크 공간을 효율적으로 관리할 수 있습니다.


## 라이센스

이 소프트웨어는 MIT 라이센스 하에 배포됩니다.