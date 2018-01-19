build: main sprite collisions input paddle
	ld65 src/*.o -C nes.cfg -o ex05-input.nes

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

clean:
	rm src/*.o
