[org 0x7c00]
[bits 16]
    xor ax, ax      ; Clear ax
    mov ds, ax      ; Set data segment to 0
    mov es, ax      ; Set extra segment to 0
    mov ss, ax      ; Set stack segment to 0
    mov sp, 0x7C00  ; Set stack pointer
    mov si, version_msg     ; Set si to bootloader version message
    call print      ; Print version
    mov si, boot_msg     ; Set si to boot message
    call print      ; Print boot message
    call enter_protected_mode
    jmp $           ; Infinite loop

print:
    lodsb           ; Load character from si into al
    or al, al       ; Check for null terminator
    jz done         ; If null, done
    mov ah, 0x0e    ; Teletype mode
    int 0x10        ; BIOS print
    jmp print       ; Next character

done:
    ret
; GDT setup
; Null descriptor
gdt_start:
	dq 0x0

; Code segment descriptor (base=0, limit=4GB, executable, 32-bit)
gdt_code:
    dw 0xFFFF        ; Limit low
	dw 0x0			 ; Base low
    db 0x0           ; Base mid
    db 10011010b     ; Access (present, code, executable)
    db 11001111b     ; Flags (4KB granularity, 32-bit) + Limit high
    db 0x0           ; Base high
    
; Data segment descriptor (base=0, limit=4GB, writable)
gdt_data:
    dw 0xFFFF        ; Limit low
	dw 0x0			 ; Base low
    db 0x0           ; Base mid
    db 10010010b     ; Access (present, data, writeable)
    db 11001111b     ; Flags (4KB granularity, 32-bit) + Limit high
    db 0x0           ; Base high
 gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

[bits 32]
protected_mode:
	mov ax, DATA_SEG        ; 5. update segment registers
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000        ; 6. setup stack
    mov esp, ebp

    [bits 16]
enter_protected_mode:
    cli             ; Disable interrupts

	mov eax, cr0
    or eax, 0x1             ; Enables protected mode
    mov cr0, eax
    jmp CODE_SEG:protected_mode ; Far jump

version_msg:
    db "Arca bootloader v0.1", 0x0A, 0

boot_msg:
    db "Arca OS booting...", 0

protected_mode_msg:
    db "Entered protected mode! Booting kernel...", 0

times 510-($-$$) db 0
dw 0xaa55
