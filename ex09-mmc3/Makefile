build: main sprite collisions input paddle background ggsound tracks
	ld65 src/*.o -C nes.cfg -o ex09-mmc3.nes

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

ggsound:
	ca65 src/ggsound.asm

tracks:
	ca65 src/tracks.asm

clean:
	rm src/*.o
