@echo off

REM Set some local variables
set loc=..\bin\cc65-snapshot-win32\bin
set dist=dist
set tmp=tmp


REM Clean
del /Q "%dist%"
del /Q "%tmp%"

REM Assemble and Link
"%loc%\ca65.exe" -g -l "%tmp%\min_mon.lst" --feature labels_without_colons -o "%tmp%\ehbasic.o" min_mon.asm
"%loc%\ld65.exe" -t none -vm -m "%tmp%\ehbasic.map" -o "%dist%\ehbasic.bin" "%tmp%\ehbasic.o"

