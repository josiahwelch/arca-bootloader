; Josiah Welch
; 8/17/25
; Arca Bootloader

[bits 16] ; Since it boots in real mode
[org 0x7c00] ; The BIOS loads the code at this address

start:
	mov si, 0 ; Uses si for counter
	;mov ax, 0x07C0 ; Sets up segment
	;mov ds, ax
	;mov es, ax
	call print
	call kernel_load

print: ; Sends hello string to screen
	mov ah, 0x0e
	mov al, [boot_msg + si] ; Increments a pointer to boot msg
	int 0x10 ; Interrupt 0x10
	inc si ; Increments counter
	cmp byte [boot_msg + si], 0 ; Checks if the counter is at the end of boot msg
	jne print ; Loops

kernel_load:
	; Load kernel from disk (sector 2)
	mov ax, 0x7E00        ; Kernel load address
	mov es, ax
	xor bx, bx            ; Buffer offset
	mov ah, 0x02          ; BIOS read sector
	mov al, 1             ; Number of sectors
	mov ch, 0             ; Cylinder
	mov dh, 0             ; Head
	mov cl, 2             ; Sector (1=boot, 2=kernel)
	int 0x13              ; BIOS disk interrupt

	; Jump to kernel
	jmp 0x7E00

jmp $ ; Creates an infinite loop, which is not ideal...

boot_msg:
	db "Arca booting...", 0 ; Boot message initialization

times  510 - ($ - $$) db 0 ; Fills the rest of the 512 byte boot sector with zeroes
dw 0xAA55 ; Magic number
