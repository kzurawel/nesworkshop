@echo off
c:\cc65\bin\ca65 src\main.asm
c:\cc65\bin\ca65 src\sprite.asm
c:\cc65\bin\ca65 src\collisions.asm
c:\cc65\bin\ca65 src\input.asm
c:\cc65\bin\ca65 src\paddle.asm
c:\cc65\bin\ca65 src\background.asm
c:\cc65\bin\ld65 src\main.o src\sprite.o src\collisions.o src\input.o src\paddle.o src\background.o -C nes.cfg -o ex06-background.nes
