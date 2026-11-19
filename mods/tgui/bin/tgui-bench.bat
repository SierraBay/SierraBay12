@echo off
rem Copyright (c) 2020 Aleksej Komarov
rem SPDX-License-Identifier: MIT
call "%~dp0..\..\..\tools\build\build.bat" --wait-on-error tgui-bench %*
exit /b %errorlevel%
