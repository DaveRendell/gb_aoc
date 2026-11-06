.PHONY: all clean

SRC := $(shell find src/ -type f -name '*.asm')
# VENDOR := $(shell find vendor/ -type f -name '*.asm')
ASM_SOURCES := ${SRC} #${VENDOR}
OBJECTS := $(patsubst %.asm,build/obj/%.o,${ASM_SOURCES})

all: dist/output.gb dist/output.map

build/img/characters.png: scripts/generate_font_tileset.py scripts/Pixelchunk.ttf
	@echo Generating characters.png
	@mkdir -p build/img
	@python3 scripts/generate_font_tileset.py

build/bin/characters.1bpp: build/img/characters.png
	@echo Converting characters.png to characters.1bpp
	@mkdir -p build/bin
	@rgbgfx -d 1 -o $@ $<

build/obj/src/2025_1/input.o: src/2025_1/input.txt

build/obj/%.o: %.asm hardware.inc build/bin/characters.1bpp
	@echo Assembling $<
	@mkdir -p $(dir $@)
	@rgbasm -o $@ $<

dist/output.gb dist/output.map &: ${OBJECTS}
	@echo Linking dist/output.gb
	@mkdir -p dist/
	@rgblink -o dist/output.gb -m dist/output.map ${OBJECTS}
	@rgbfix -v -m mbc1 -p 0xFF dist/output.gb

clean:
	rm -rf dist build