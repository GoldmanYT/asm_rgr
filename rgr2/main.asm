		includelib	kernel32.lib
		includelib	user32.lib
		extern	ExitProcess: proc
		extern	SystemParametersInfoA: proc
		extern	ReadConsoleA: proc
		extern	WriteConsoleA: proc
		extern	GetStdHandle: proc
		extern	SetConsoleTitleA: proc

.data
consoleTitle	db	'Set menu drop alignment', 0

msg1		db	'Your value of menu drop alignment is '
len1		dq	$-msg1

msg2		db	13, 10, 'Press [Enter] to change the value.'
len2		dq	$-msg2

msg3		db	'Success! Now your value of menu drop alignment is '
len3		dq	$-msg3

msg4		db	'Error! Change failed.'
len4		dq	$-msg4

msg5		db	'Error! Can not get the menu drop alignment.'
len5		dq	$-msg5

hin		dq	0
hout		dq	0
tmp1		db	0
tmp2		dd	0
one		dq	1

menuAlignment	db	0

.code
WaitEnter	macro
		mov	rcx, hin
		mov	rdx, offset tmp1
		mov	r8, 1
		mov	r9, offset tmp2
		mov	qword ptr [rsp + 32], 0
		call	ReadConsoleA
		endm

WriteMessage	macro	msg, len
		mov	rcx, hout
		mov	rdx, offset msg
		mov	r8, [len]
		mov	r9, offset tmp2
		mov	qword ptr [rsp + 32], 0
		call	WriteConsoleA
		endm

GetAlignment	macro
		mov	rcx, 27		; SPI_GETMENUGROPALIGNMENT = 27
		xor	rdx, rdx	; uiParam = NULL
		mov	r8, offset menuAlignment	; pvParam = (bool*)menuAlignment
		xor	r9, r9		; fWinIni = NULL
		call	SystemParametersInfoA
		endm

WinMain		proc
		sub	rsp, 40
		mov	rcx, offset consoleTitle
		call	SetConsoleTitleA

		mov	rcx, -10	; STD_INPUT_HANDLE = -10
		call	GetStdHandle
		mov	hin, rax

		mov	rcx, -11	; STD_OUTPUT_HANDLE = -11
		call	GetStdHandle
		mov	hout, rax

		GetAlignment

		test	rax, rax
		jz	fail_get

		WriteMessage	msg1, len1
		add	menuAlignment, '0'
		WriteMessage	menuAlignment, one
		sub	menuAlignment, '0'
		WriteMessage	msg2, len2
		WaitEnter

		mov	rcx, 28		; SPI_SETMENUGROPALIGNMENT = 28

		xor	rdx, rdx
		mov	dl, menuAlignment
		test	rdx, rdx	
		jnz	set_0		; Если menuAligntment != 0, то поставить 0
set_1:		mov	dl, 1		; Иначе поставить 1
		jmp	end_set
set_0:		xor	rdx, rdx
end_set:
		xor	r8, r8		; pvParam = NULL
		mov	r9, 2		; fWinIni = 1 - Сохранить в реестр
		call	SystemParametersInfoA

		test	rax, rax
		jz	fail_set

		GetAlignment
		WriteMessage	msg3, len3
		add	menuAlignment, '0'
		WriteMessage	menuAlignment, one
		WaitEnter
		jmp	exit
		
fail_get:	WriteMessage	msg5, len5
		WaitEnter
		jmp	exit

fail_set:	WriteMessage	msg4, len4
		WaitEnter
		jmp	exit

exit:		xor	rcx, rcx
		call	ExitProcess

WinMain		endp
		end
