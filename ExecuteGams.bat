@echo off
REM Set the path to your GAMS installation if not already in PATH
SET GAMS_PATH=C:\GAMS\win64\25.1

REM Change directory to where your .gms file is located
cd C:\Alejo\cops

REM Run the GAMS model file
"%GAMS_PATH%\gams.exe" Main_COPS.gms