@echo off

REM Set some local variables
set loc=..\bin\cc65-snapshot-win32\bin
set dist=dist
set tmp=tmp

REM Clean
del /Q "%dist%"
del /Q "%tmp%"

REM Assemble and Link
"%loc%\ca65.exe" --feature labels_without_colons -D mon "mon.asm" -o "%tmp%\mon.o"
"%loc%\ld65.exe" -C "mon.cfg" "%tmp%\mon.o" -o "%dist%\Potpourri6502.bin" -Ln "%tmp%\mon.lbl"
