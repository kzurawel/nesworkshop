build: main sprite collisions input paddle background
	ld65 src/*.o -C nes.cfg -o ex07-scrolling.nes

main:
	ca65 src/main.asm

sprite:
	ca65 src/sprite.asm

collisions:
	ca65 src/collisions.asm

input:
	ca65 src/input.asm

paddle:
	ca65 src/paddle.asm

background:
	ca65 src/background.asm

clean:
	rm src/*.o
