extern putchar
extern printint

global	_start

section .data
	logfile db "log.txt", 0
section .bss
	count	resd 256
	buff	resb 4096
	fin		resd 1
	fout	resd 1

section .text
_start:
	mov ebp, esp
	cmp dword [ebp], 2	; check num of params
	jne quit

	xor eax, eax
	mov edi, count;
	mov ecx, 256
	cld
	rep stosd			; init array with 0

	mov eax, 5			; open
	mov ebx, [ebp+8]	; pathname from params
	mov ecx, 0			; RDONLY
	int 80h

	mov [fin], eax		; save filedescriptor

	mov eax, 5
	mov ebx, logfile
	mov ecx, 241h		; TRUNC|CREATE|RDONLY
	mov edx, 0666q		; rw-rw-rw-
	int 80h

	mov [fout], eax

.read:
	mov	eax, 3		
	mov	ebx, [fin]
	mov ecx, buff
	mov	edx, 4096
	int 0x80

	cmp eax, 0
	je endcounting

	cmp eax, -1
	je endcounting

	mov esi, buff
	mov ecx, eax
	cld

.lp: lodsb			; count symbols from buff
	xor ebx, ebx
	mov bl, al
	lea ebx, [count+ebx*4]
	inc dword [ebx]	
	loop .lp
	
	jmp .read

endcounting:

	sub esp, 8

	mov eax, [fout]			; set fd param for print and put
	mov dword [esp], eax

	mov esi, count
	mov ecx, 256
	mov ebx, 0	
	cld
	
.print_count: lodsd						
	mov edx, eax
	mov byte [esp+4], bl
	call putchar	
	mov byte [esp+4], ':'
	call putchar	
	mov byte [esp+4], ' '
	call putchar	

	mov dword [esp+4], edx
	call printint

	mov byte [esp+4], 10
	call putchar	

	inc bl
	loop .print_count

	add esp, 8

	mov eax, 6				; close file
	mov ebx, fin
	int 80h

	mov eax, 6
	mov ebx, fout
	int 80h

quit:
	mov ebx, 0
	mov eax, 1	; exit
	int 0x80
