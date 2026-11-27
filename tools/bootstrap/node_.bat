@echo off
setlocal EnableExtensions

set "NODE_EXE="

if /i "%SIERRA_FORCE_PORTABLE_NODE%"=="1" goto bootstrap

for /f "delims=" %%i in ('where node 2^>nul') do (
  if not defined NODE_EXE (
    "%%~fi" -e "process.exit(Number(process.versions.node.split('.')[0])>=20?0:1)" >nul 2>nul && set "NODE_EXE=%%~fi"
  )
)

:bootstrap
if not defined NODE_EXE (
  for /f "usebackq delims=" %%i in (`""%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0ensure-node.ps1""`) do (
    if not defined NODE_EXE set "NODE_EXE=%%~fi"
  )
)

if not defined NODE_EXE (
  echo ERROR: Failed to locate or bootstrap Node.js. 1>&2
  exit /b 1
)

if not exist "%NODE_EXE%" (
  echo ERROR: Node.js executable was not found at "%NODE_EXE%". 1>&2
  exit /b 1
)

for %%d in ("%NODE_EXE%") do set "NODE_DIR=%%~dpd"
set "PATH=%NODE_DIR%;%PATH%"

"%NODE_EXE%" %*
exit /b %errorlevel%
