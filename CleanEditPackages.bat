@echo off
color 0F
title ClientBTimes
cd..
cd system
:remove
ucc.exe MakeCommandletUtils.EditPackagesCommandlet 0 ClientBTimesV4D
pause
goto remove