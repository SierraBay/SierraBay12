@echo off
setlocal
set "BUILD_SCRIPT=%~dp0build.js"
set "BUILD_WAIT_ON_ERROR="
set "BUILD_CI="
if "%~1"=="" set "BUILD_WAIT_ON_ERROR=1"

:options
if "%~1"=="" goto run
if /i "%~1"=="--wait-on-error" set "BUILD_WAIT_ON_ERROR=1"
if /i "%~1"=="--ci" set "BUILD_CI=1"
shift
goto options

:run
where node >nul 2>nul
if errorlevel 1 (
  echo ERROR: Node.js was not found on PATH. Install Node.js and reopen the terminal.
  set "BUILD_EXIT_CODE=1"
  goto finish
)
node "%BUILD_SCRIPT%" %*
set "BUILD_EXIT_CODE=%errorlevel%"

:finish
if "%BUILD_EXIT_CODE%"=="0" goto done
if not defined BUILD_WAIT_ON_ERROR goto done
if defined BUILD_CI goto done
if defined CI goto done
if /i "%CBT_BUILD_MODE%"=="TGS" goto done
echo Build failed with exit code %BUILD_EXIT_CODE%. See the error above.
pause

:done
exit /b %BUILD_EXIT_CODE%
