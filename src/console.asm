INCLUDE "hardware.inc"
INCLUDE "src/charmap.inc"

SECTION "ConsoleVars", wram0
; Pointer to the tile in VRAM Tilemap 0 at the start of the line we're
; currently writing to.
linePointer: dw
; The line number in the tilemap we're on - used to track when to scroll the
; screen to keep new lines visible.
; Note - we only use the bottom 5 bits (Tilemap has 32 lines)
lineNumber: db
; Current character offset on current line
cursorXOffset: db

SECTION "Console", rom0
ConsoleInit::
    ld a, LOW(TILEMAP0)
    ld [linePointer], a
    ld a, HIGH(TILEMAP0)
    ld [linePointer + 1], a
    xor a
    ld [cursorXOffset], a
    ld [lineNumber], a
    ret

; Waits for next VBLank and writes text to screen
; @param de pointer to string
; @param b string length
; @clobbers hl, a
ConsolePrint::
    call SetPointerToNextChar

    ; Increment cursorXOffset by b
    ld a, [cursorXOffset]
    add a, b
    ld [cursorXOffset], a

    call WaitForVBlank

    ; Load string data into tilemap
:   ld a, [de]
    ld [hli], a
    inc de
    dec b
    jr nz, :-

    ret

; Print a single ASCII character
; @param b - the character to print
; @clobbers hl, a
ConsolePrintChar::
    call SetPointerToNextChar

    ; Increment cursorXOffset by 1
    ld a, [cursorXOffset]
    inc a
    ld [cursorXOffset], a

    call WaitForVBlank

    ld [hl], b

    ret

; Print a single numeric byte in 2 digit hexidecimal
; @param b - the character to print
; @clobbers hl, a, c
ConsolePrintInt::
    ld a, b
    ld c, b
    swap a
    and a, $F
    add a, CHARVAL("0")
    ld b, a
    call ConsolePrintChar
    ld a, c
    and a, $F
    add a, CHARVAL("0")
    ld b, a
    call ConsolePrintChar
    ld b, c
    ret

; Move the console cursor to the start of the next line, and clear it
; @clobbers a, b
ConsoleNewLine::
    ld a, [linePointer]
    add a, TILEMAP_WIDTH
    ld [linePointer], a
    ld a, [linePointer + 1]
    adc 0
    ld [linePointer + 1], a
    xor a
    ld [cursorXOffset], a

    ld a, [lineNumber]
    inc a
    ; If a = 32, reset to top of screen
    cp a, TILEMAP_HEIGHT
    jr nz, :+
    call ConsoleInit
:   ld [lineNumber], a

    and a, $1F ; Line number wraps around at 32
    ld [lineNumber], a
    ld b, a

    ldh a, [rSCY]
    rra 
    rra
    rra ; a /= 8
    add a, SCREEN_HEIGHT
    and a, $1F; a = last visible scanline
    
    ; If current line is not the last visible one, return
    cp a, b
    ret nz

    cp a, SCREEN_HEIGHT
    ; If it is, scroll down by one line
    ldh a, [rSCY]
    add a, TILE_HEIGHT
    ldh [rSCY], a

    ; Clear line
    call SetPointerToNextChar
    ld b, TILEMAP_WIDTH
    xor a
:   ld [hli], a
    dec b
    jr nz, :-
    
    ret

; Sets hl to point at next tile in tilemap that characters should be written to
; @returns hl
; @clobbers a
SetPointerToNextChar:
    ld a, [linePointer]
    ld l, a
    ld a, [linePointer + 1]
    ld h, a
    ld a, [cursorXOffset]
    add a, l
    ld l, a
    ld a, h
    adc 0
    ld h, a
    ret

; Stalls until first line of VBlank
; @clobbers a
WaitForVBlank:
:   ldh a, [rLY]
	cp LY_VBLANK
	jr nz, :-
    ret