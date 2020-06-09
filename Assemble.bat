setlocal enableExtensions disableDelayedExpansion

ca65 Source/Source.asm
ca65 Source/Reset.asm
ca65 Source/Main.asm

ld65 Source/Source.o Source/Main.o Source/Reset.o -C nes.cfg -o test.nes

cmd /K