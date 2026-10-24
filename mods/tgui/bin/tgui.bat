@echo off
rem Copyright (c) 2020 Aleksej Komarov
rem SPDX-License-Identifier: MIT
setlocal
set "TGUI_BIN_DIR=%~dp0"

if "%1"=="dev" goto dev
if "%1"=="--dev" goto dev
if "%1"=="tgui-dev" goto dev
if "%1"=="bench" goto bench
if "%1"=="--bench" goto bench
if "%1"=="tgui-bench" goto bench
if "%1"=="build" goto build
if "%1"=="--build" goto build
if "%1"=="tgui-build" goto build
if "%1"=="clean" goto clean
if "%1"=="--clean" goto clean
if "%1"=="prettier" goto prettier
if "%1"=="--prettier" goto prettier
if "%1"=="tgui-prettier" goto prettier
if "%1"=="font" goto font
if "%1"=="--font" goto font
if "%1"=="tgfont" goto font

call "%TGUI_BIN_DIR%..\..\..\tools\build\build.bat" --wait-on-error tgui tgui-lint tgui-test %*
exit /b %errorlevel%

:dev
shift
call "%TGUI_BIN_DIR%tgui-dev.bat" %1 %2 %3 %4 %5 %6 %7 %8 %9
exit /b %errorlevel%

:bench
shift
call "%TGUI_BIN_DIR%tgui-bench.bat" %1 %2 %3 %4 %5 %6 %7 %8 %9
exit /b %errorlevel%

:build
shift
call "%TGUI_BIN_DIR%tgui-build.bat" %1 %2 %3 %4 %5 %6 %7 %8 %9
exit /b %errorlevel%

:clean
shift
call "%TGUI_BIN_DIR%clean.bat" %1 %2 %3 %4 %5 %6 %7 %8 %9
exit /b %errorlevel%

:prettier
shift
call "%TGUI_BIN_DIR%tgui-prettier.bat" %1 %2 %3 %4 %5 %6 %7 %8 %9
exit /b %errorlevel%

:font
shift
call "%TGUI_BIN_DIR%tgfont.bat" %1 %2 %3 %4 %5 %6 %7 %8 %9
exit /b %errorlevel%

