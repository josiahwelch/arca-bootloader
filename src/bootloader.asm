; Josiah Welch
; 8/17/25
; Arca Bootloader

bits 16 ; Since it boots in real mode
org 0x7c00 ; The BIOS loads the code at this address

mov si, 0 ; Uses si for counter

print:
	mov ah, 0x0e
	mov al, [hello + si] ; Increments a pointer to hello string
	int 0x10 ; Interrupt 0x10
	inc si ; Increments counter
	cmp byte [hello + si], 0 ; Checks if the counter is at the end of hello string
	jne print ; Loops

jmp $ ; Creates an infinite loop, which is not ideal...

hello:
	db "Hello, World!", 0 ; Hello string initialization

times  510 - ($ - $$) db 0 ; Fills the rest of the 512 byte boot sector with zeroes
dw 0xAA55 ; Magic number

