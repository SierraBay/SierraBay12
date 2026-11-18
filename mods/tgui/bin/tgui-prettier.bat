@echo off
rem Copyright (c) 2020 Aleksej Komarov
rem SPDX-License-Identifier: MIT
call "%~dp0..\..\..\tools\build\build.bat" --wait-on-error tgui-prettier %*
exit /b %errorlevel%
