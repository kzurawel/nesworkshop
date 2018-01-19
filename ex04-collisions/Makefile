build: main sprite collisions
	ld65 src/*.o -C nes.cfg -o ex04-collisions.nes

main:
	ca65 src/main.asm

sprite:
	ca65 src/sprite.asm

collisions:
	ca65 src/collisions.asm

clean:
	rm src/*.o
