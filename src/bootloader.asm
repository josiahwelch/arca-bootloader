[org 0x7c00]
    xor ax, ax      ; Clear ax
    mov ds, ax      ; Set data segment to 0
    mov es, ax      ; Set extra segment to 0
    mov si, version_msg     ; Set si to point to the bootloader version message
    call print      ; Call print function
	int 0x21
    mov si, boot_msg     ; Set si to point to the boot message
    call print      ; Call print function
    jmp $           ; Infinite loop

print:
    lodsb           ; Load character from si into al
    or al, al       ; Check for null terminator
    jz done         ; If null terminator, jump to done
    mov ah, 0x0e    ; Set teletype mode
    int 0x10        ; Call BIOS interrupt to print character
    jmp print       ; Loop back to print next character

done:
    ret

protected_mode:
	cli ; Disables interrupts

	; Segment registers
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0x7C00

	lgdt [gdt_descriptor] ; Loads GDT

	; Switches to protected mode (32 bit)
	mov eax, cr0
	or eax, 1
	mov cr0, eax

	jmp 0x08:protected_mode ; Far jump to 32-bit code


version_msg:
    db "Arca bootloader v0.1", 0x0A, 0 ; Null-terminated message string

boot_msg:
    db "Arca OS booting...", 0 ; Null-terminated message string

times 510-($-$$) db 0 ; Fill the rest of the sector with 0s
dw 0xaa55 ; Boot signature
