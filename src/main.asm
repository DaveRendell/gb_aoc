include "hardware.inc"
include "src/charmap.inc"

SECTION "VBlankInterrupt", rom0[INT_HANDLER_VBLANK]
    jp VBlank
    ds INT_HANDLER_STAT - @, 0

SECTION "Header", rom0[$100]
	jp Init

	ds $150 - @, 0 ; Make room for the header

SECTION "CharacterTiles", rom0
CharacterTiles:
	incbin "build/bin/characters.1bpp"
.end:

SECTION "Init", rom0
Init:
    di
    ; Initialise stack pointer
    ld sp, $FFFE

    ; Reset background scroll to zero
	xor a
	ldh [rSCX], a
	ldh [rSCY], a

    ; Wait for VBlank to turn off the screen
:	ldh a, [rLY]
	cp LY_VBLANK
	jr c, :-

    xor a
	ld [rLCDC], a

    ; Clear OAM
	ld hl, STARTOF(OAM)
	ld bc, OAM_SIZE
	call MemClear
	
	; Clear Nintendo logo from VRAM
	ld hl, STARTOF(VRAM)
	ld bc, TILE_SIZE * CHARVAL(" ")
	call MemClear

	; Load characters into VRAM at tile IDs matching ASCII values
	ld hl, STARTOF(VRAM) + TILE_SIZE * CHARVAL(" ")
	ld de, CharacterTiles
	ld bc, CharacterTiles.end - CharacterTiles
	call MemCopy1bpp

    ; Turn the LCD on
	ld a, LCDC_ON \
		| LCDC_BG_ON \
		| LCDC_OBJ_ON \
		| LCDC_OBJ_8 \
		| LCDC_BG_9800 \
		| LCDC_BLOCK01
	ld [rLCDC], a

    ; During the first (blank) frame, initialize display registers
	ld a, $E4
	ld [rBGP], a
	ld a, $E4
	ld [rOBP0], a
	
	; Setup complete

	; Test printing characters A -> Z
	call ConsoleInit
	REPT 3
	ld c, CHARVAL("A")
:
	push bc
	ld de, TestString
	ld b, TestString.end - TestString
	call ConsolePrint
	pop bc
	ld b, c
	call ConsolePrintChar
	call ConsoleNewLine

	inc c
	ld a, CHARVAL("Z") + 1
	cp a, c
	jr nz, :-
	ENDR

MainLoop:
	nop
    jr MainLoop

TestString:
	db "Character: "
.end
