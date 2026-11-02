SECTION "Utils", rom0

; Copy bytes from one area to another.
; Ensure bc != 0 on pass to avoid memory corruption.
; @param de: Source
; @param hl: Destination
; @param bc: Length
MemCopy::
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or a, c
    jr nz, MemCopy
    ret

; Copy 1bpp bytes into VRAM
; Ensure bc != 0 on pass to avoid memory corruption.
; @param de: Source
; @param hl: Destination
; @param bc: Source length
MemCopy1bpp::
    ld a, [de]
    ld [hli], a
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or a, c
    jr nz, MemCopy1bpp
    ret

; Initialise memory in an area to 0
; Ensure bc != 0 on pass to avoid memory corruption.
; @param hl: AreaStart
; @param bc: Length
MemClear::
    xor a
    ld [hli], a
    dec bc
    ld a, b
    or a, c
    jr nz, MemClear
    ret