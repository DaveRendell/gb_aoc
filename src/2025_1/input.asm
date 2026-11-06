; Input file is ~19K. Won't quite fit in a single 16K bank. Split into 5 <4K
; chunks?
DEF CHUNK_SIZE = 4096
DEF CHUNK_COUNT = 5
FOR CHUNK_I, CHUNK_COUNT - 1
    SECTION "Input_2025_Part_1_Chunk_{CHUNK_I}", romx
    Input2025Part1Chunk{d:CHUNK_I}::
    incbin "src/2025_1/input.txt", CHUNK_I * CHUNK_SIZE, CHUNK_SIZE
    .end::
ENDR

; Final chunk needs to have unbounded size, so listed separately
; TODO, way to avoid doing this?
DEF FINAL_CHUNK_I = CHUNK_COUNT - 1
SECTION "Input_2025_Part_1_Chunk_{FINAL_CHUNK_I}", romx
Input2025Part1Chunk{d:CHUNK_I}::
incbin "src/2025_1/input.txt", FINAL_CHUNK_I * CHUNK_SIZE
.end::