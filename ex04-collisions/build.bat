@echo off
c:\cc65\bin\ca65 src\main.asm
c:\cc65\bin\ca65 src\sprite.asm
c:\cc65\bin\ca65 src\collisions.asm
c:\cc65\bin\ld65 src\main.o src\sprite.o src\collisions.o -C nes.cfg -o ex04-collisions.nes
