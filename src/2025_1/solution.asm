INCLUDE "hardware.inc"
INCLUDE "src/charmap.inc"

DEF INPUT_CHUNK_COUNT = 5

SECTION "Solution_2025_1_Data", rom0
; Table of the input data chunks
; bank (db)
; address (dw)
; length (dw)
InputDataChunks:
FOR CHUNK_I, INPUT_CHUNK_COUNT
    db BANK(Input2025Part1Chunk{d:CHUNK_I})
    dw Input2025Part1Chunk{d:CHUNK_I}
    dw Input2025Part1Chunk{d:CHUNK_I}.end - Input2025Part1Chunk{d:CHUNK_I}
ENDR
title: db " AoC 2025 Day 1"
.end:
part1: db " Part 1: "
.end
part2: db " Part 2: "
.end

SECTION "Solution_2025_1_Vars", wram0
; Stores ascii for either "R" or "L", defines what direction current line
; describes
direction: db
; 4 digit binary encoded decimal buffer for reading the current line into
; (In input max 3 digits are present)
bcdLineBuffer: ds 2
; Current safe state (2 digit bcd number)
safeState: db
; Count how many times we land on zero
part1Answer: ds 2
; Count how many time we pass through zero
part2Answer: ds 2

SECTION "Solution_2025_1_Code", rom0
Solution20251::
    call ConsoleNewLine
    ld de, title
    ld b, title.end - title
    call ConsolePrint
    call ConsoleNewLine
    call ConsoleNewLine

    ld c, INPUT_CHUNK_COUNT
    ld hl, InputDataChunks

    ld a, $50
    ld [safeState], a
    xor a
    ld [part1Answer], a
    ld [part1Answer + 1], a
    ld [part2Answer], a
    ld [part2Answer + 1], a
    ld [direction], a
    ld [bcdLineBuffer], a
    ld [bcdLineBuffer + 1], a

.chunkTableLoop:
    push bc

    ; Switch ROM bank to current chunk
    ld a, [hli] ; a = bank
    ld [rROMB], a

    ld e, [hl]
    inc hl
    ld d, [hl] ; de = chunk address
    inc hl
    ld c, [hl]
    inc hl
    ld b, [hl] ; bc = chunk length
    inc hl

    push hl

    push de
    pop hl ; hl now points at start of chunk

    ld d, -1 ; counts digits (-1 to account for R/L)

.chunkLoop:
    ld a, [hli]
    push hl
    push bc

    cp a, CHARVAL("R")
    jr nz, :+
    call SetDirection
    jr .next

:   cp a, CHARVAL("L")
    jr nz, :+
    call SetDirection
    jr .next
    

:   cp a, CHARVAL("\n")
    jr nz, :+
    call ProcessLine
    jr .next

:   call PushDigit

.next:
    pop bc
    pop hl
    dec bc
    ld a, b
    or c
    jr nz, .chunkLoop


    pop hl
    pop bc
    dec c
    jr nz, .chunkTableLoop

    ; Print answers
    ld de, part1
    ld b, part1.end - part1
    call ConsolePrint
    ld a, [part1Answer + 1]
    ld b, a
    call ConsolePrintInt
    ld a, [part1Answer]
    ld b, a
    call ConsolePrintInt
    call ConsoleNewLine

    ld de, part2
    ld b, part2.end - part2
    call ConsolePrint
    ld a, [part2Answer + 1]
    ld b, a
    call ConsolePrintInt
    ld a, [part2Answer]
    ld b, a
    call ConsolePrintInt
    call ConsoleNewLine

    ret

; Store a in the direction var
SetDirection:
    ld [direction], a
    ret

; Push digit to bcd buffer
; @param a - ascii code for digit
; @clobbers b
PushDigit:
    push hl
    ; Aim: ABCD -> BXDA
    sub a, CHARVAL("0")
    ld b, a
    ld hl, bcdLineBuffer
    swap [hl] ; BACD
    inc hl
    swap [hl] ; BADC
    ld a, [hl];
    and a, $F0
    ld [hld], a ; BAD0
    ld a, [hli] ; a = BA
    and a, $0F ; a = 0A
    or a, [hl] ; a = DA
    ld [hld], a ; BADA
    ld a, [hl] ; a = BA
    and a, $F0 ; a = B0
    or a, b ; a = BX
    ld [hl], a

    pop hl
    ret

ProcessLine:
    ld a, [direction]
    ld hl, safeState

    cp a, CHARVAL("R")
    jr nz, .left

.right:
    ld a, [bcdLineBuffer]
    ld b, a
    ld a, [safeState]
    ld c, a
    add a, b
    jr .calculate
.left:
    ld a, [bcdLineBuffer]
    ld b, a
    ld a, [safeState]
    ld c, a
    sub a, b

.calculate
    daa
    ld [safeState], a

    ; If calculation carried, increment part 2 answer, and if also at zero,
    ; increment part 1 answer too
    jr nc, .didNotCarry
    ld a, c
    and a
    call nz, IncrementPart2
    ld a, [safeState]
    and a
    call z, IncrementPart1
    jr .handleHundredsDigit

.didNotCarry:
    ; If it didn't carry, increment both if it was zero (coming from above)
    jr nz, .handleHundredsDigit
    call IncrementPart1
    call IncrementPart2

.handleHundredsDigit:
    ; We can add the hundreds digit to the part 2 answer directly, each hundred
    ; is a loop through 0
    ld a, [bcdLineBuffer + 1]
    and a
    jr z, .resetVars
    ld b, a
    ld a, [part2Answer]
    add a, b
    daa
    ld [part2Answer], a
    ld a, [part2Answer + 1]
    adc a, 0
    daa
    ld [part2Answer + 1], a

    ; Reset vars for next line
.resetVars:
    xor a
    ld [direction], a
    ld [bcdLineBuffer], a
    ld [bcdLineBuffer + 1], a
    ret
    
IncrementPart1:
    ld a, [part1Answer]
    add a, 1
    daa
    ld [part1Answer], a
    ld a, [part1Answer + 1]
    adc a, 0
    daa
    ld [part1Answer + 1], a
    ret

IncrementPart2:
    ld a, [part2Answer]
    add a, 1
    daa
    ld [part2Answer], a
    ld a, [part2Answer + 1]
    adc a, 0
    daa
    ld [part2Answer + 1], a
    ret
