
@echo off

REM This file builds various versions of Microsoft BASIC for 6502 based computers.
 

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

REM Iterate through each version of BASIC and build.
for %%s in (applesoft cbmbasic1 cbmbasic2 kb9 kbdbasic microtan osi potpourri6502) do (
    "%loc%\ca65.exe" -D %%s msbasic.s -o "%tmp%\%%s.o"
    "%loc%\ld65.exe" -C "cfg\%%s.cfg" "%tmp%\%%s.o" -o "%dist%\%%s.bin" -Ln "%tmp%\%%s.lbl"
)

