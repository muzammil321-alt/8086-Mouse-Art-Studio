; ************************************************************
; Project: Mouse-Driven ASCII Art Studio
; Developer: Muhammed Muzammil (Muzi)
; Logic: Interrupt 33h for Mouse & B800h for Video Buffer
; ************************************************************

ORG 100h

START:
    ; --- Step 1: Initialize Mouse ---
    MOV AX, 0           ; Function 0: Reset/Initialize mouse
    INT 33H
    CMP AX, 0           ; Check if mouse driver exists
    JE  NO_MOUSE

    ; --- Step 2: Show Mouse Pointer ---
    MOV AX, 1           ; Function 1: Show mouse cursor
    INT 33H

    ; --- Step 3: Set Video Mode (Text Mode 80x25) ---
    MOV AX, 0003h       ; Standard text mode
    INT 10h

    ; --- Step 4: Main Drawing Loop ---
DRAW_LOOP:
    ; Check for Keyboard Escape (To exit)
    MOV AH, 01h
    INT 16h
    JNZ EXIT_PROG       ; If key pressed, exit

    ; Get Mouse Status
    MOV AX, 3           ; Function 3: Get mouse position & button status
    INT 33H
    ; BX returns button state (1 = Left, 2 = Right)
    ; CX = X coordinate (0-639)
    ; DX = Y coordinate (0-199)

    CMP BX, 1           ; Check if Left Click is pressed
    JNE DRAW_LOOP       ; If not, keep polling

    ; --- Step 5: Convert Mouse Coords to Text Grid (Divide by 8) ---
    SHR CX, 3           ; CX = CX / 8 (X pos in 80 columns)
    SHR DX, 3           ; DX = DX / 8 (Y pos in 25 rows)

    ; Calculate Memory Offset: (Y * 80 + X) * 2
    MOV AX, 80
    MUL DX              ; AX = Y * 80
    ADD AX, CX          ; AX = (Y * 80) + X
    SHL AX, 1           ; AX = AX * 2 (Each char takes 2 bytes: char + color)
    MOV DI, AX

    ; --- Step 6: Write to Video Buffer (Direct Memory Access) ---
    MOV AX, 0B800h      ; Video segment address
    MOV ES, AX
    MOV AL, 219         ; ASCII 219 is a solid block '█'
    MOV AH, 0Fh         ; Color: White text on Black background
    MOV ES:[DI], AX     ; Write to direct video memory!

    JMP DRAW_LOOP

NO_MOUSE:
    ; Error handling if mouse not found
    RET

EXIT_PROG:
    MOV AX, 2           ; Hide mouse cursor before exit
    INT 33H
    RET
END
