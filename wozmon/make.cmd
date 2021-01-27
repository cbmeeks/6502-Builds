
@echo off

REM This file builds the WOZ monitor
 

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


"%loc%\ca65.exe" -D wozmon "wozmon.s" -o "%tmp%\wozmon.o"
"%loc%\ld65.exe" -C "wozmon.cfg" "%tmp%\wozmon.o" -o "%dist%\wozmon.bin" -Ln "%tmp%\wozmon.lbl"

