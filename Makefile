.PHONY: all clean

SRC := $(shell find src/ -type f -name '*.asm')
# VENDOR := $(shell find vendor/ -type f -name '*.asm')
ASM_SOURCES := ${SRC} #${VENDOR}
OBJECTS := $(patsubst %.asm,build/obj/%.o,${ASM_SOURCES})

all: dist/output.gb dist/output.map

build/obj/%.o: %.asm hardware.inc
	@echo Assembling $<
	@mkdir -p $(dir $@)
	@rgbasm -o $@ $<

dist/output.gb dist/output.map &: ${OBJECTS}
	@echo Linking dist/output.gb
	@mkdir -p dist/
	@rgblink -o dist/output.gb -m dist/output.map ${OBJECTS}
	@rgbfix -v -p 0xFF dist/output.gb

clean:
	rm -rf dist build