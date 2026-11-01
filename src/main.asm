include "hardware.inc"

SECTION "VBlankInterrupt", rom0[INT_HANDLER_VBLANK]
    jp VBlank
    ds INT_HANDLER_STAT - @, 0

SECTION "Header", rom0[$100]
	jp Init

	ds $150 - @, 0 ; Make room for the header

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

    ; Turn the LCD on
	ld a, LCDC_ON | LCDC_BG_ON | LCDC_OBJ_ON | LCDC_OBJ_8
	ld [rLCDC], a

    ; During the first (blank) frame, initialize display registers
	ld a, $e4
	ld [rBGP], a
	ld a, $e4
	ld [rOBP0], a

    ; Set up interrupts
	ld a, IE_VBLANK
	ld [rIE], a

    ; Clean rIF and enable interrupts
	xor a
	ldh [rIF], a
    ei 
    ; Fall through into main loop
MainLoop:
    ld b, b
    halt
    jr MainLoop

