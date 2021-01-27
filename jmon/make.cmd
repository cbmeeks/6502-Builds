
@echo off

REM This file builds the JMON monitor
REM https://github.com/jefftranter/6502/blob/master/asm/6551acia/jmon.s
REM Uses a 6551 ACIA
 

REM "dist" folder is where the final binaries are copied. 
REM "tmp" folder is a working directory.
REM Both directories will be emptied before running.
REM "loc" folder is where the ca65.exe is located.
REM All folders use relative paths.

REM Set some local variables
set loc=..\bin\cc65-snapshot-win32\bin
set dist=dist
set tmp=tmp

REM Clean folders
del /Q "%dist%"
del /Q "%tmp%"


"%loc%\ca65.exe" -D jmon "jmon.s" -o "%tmp%\jmon.o"
"%loc%\ld65.exe" -C "jmon.cfg" "%tmp%\jmon.o" -o "%dist%\jmon.bin" -Ln "%tmp%\jmon.lbl"

