mkdir build
pushd build
pushd Debug

@echo off 

REM ##1.expand life duration of variable
setlocal enabledelayedexpansion

REM ##2.set variables
set a=0
set var=

REM ##3.standard for cycle, use delims to set delimiter,
for /f "delims=" %%a in ('dir /b *.exe') do (
set var=%%a
)
windeployqt --qmldir ..\..\src !var!
echo deploy finish
cd ../../


