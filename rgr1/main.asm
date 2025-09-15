		includelib	../kernel32.lib
		includelib	../user32.lib
		extern	ExitProcess: proc
		extern  MessageBoxA: proc
		extern  wsprintfA: proc

.data
MsgCaption	db	"cpuid", 0
vendorId	db	13 dup(0)
brandString	db	"Brand string not supported", 24 dup(0)
fmt		db	"Vendor ID: %s", 13, 10
		db	"CPU: %s", 13, 10
		db	"Physical memory: 2^%d", 13, 10
		db	"Linear memory: 2^%d", 0
MsgBoxText	db	256 dup(0)

.code
WinMain		proc
		sub	rsp, 7 * 8	; выделить стек для передачи параметров + выравнивание
		lea	rdi, vendorId

		xor	rax, rax	; eax = 0
		cpuid			; получить Vendor ID
		mov	[rdi], ebx	; сохранить
		mov	[rdi + 4], edx	; в строку
		mov	[rdi + 8], ecx

		mov	eax, 80000000h	; проверить поддержку
		cpuid			; строки бренда
		test	eax, 80000000h	; если не поддерживается
		jz	fin		; то перейти
		cmp	eax, 80000004h	; или поддерживается не полностью
		jb	fin

		lea	rdi, brandString
		mov	eax, 80000002h	; получить 1-ю часть
		cpuid			; строки бренда
		mov	[rdi], eax	; сохранение в строку
		mov	[rdi + 4], ebx
		mov	[rdi + 8], ecx
		mov	[rdi + 12], edx

		mov	eax, 80000003h	; получить 2-ю часть
		cpuid			; строки бренда
		mov	[rdi + 16], eax	; сохранение в строку
		mov	[rdi + 20], ebx
		mov	[rdi + 24], ecx
		mov	[rdi + 28], edx

		mov	eax, 80000004h	; получить 3-ю часть
		cpuid			; строки бренда
		mov	[rdi + 32], eax	; сохранение в строку
		mov	[rdi + 36], ebx
		mov	[rdi + 40], ecx
		mov	[rdi + 44], edx

fin:		xor	rdi, rdi	; обнуляем ответ (кол-во бит физ. адреса)
		xor	rsi, rsi	; обнуляем ответ (кол-во бит лин. адреса)
		mov	eax, 80000008h	; получить размер линейного (физического) адреса
		cpuid
		mov	dil, al		; ответ в rdi (кол-во бит физ. адреса)
		shr	rax, 8
		mov	sil, al		; ответ в rsi (кол-во бит лин. адреса)
		; формирование строки с результатом
		mov	rcx, offset MsgBoxText
		mov	rdx, offset fmt
		mov	r8, offset vendorId
		mov	r9, offset brandString
		mov	[rsp + 32], rdi
		mov	[rsp + 40], rsi
		call	wsprintfA
		; вывод результата
		xor	rcx, rcx
		mov	rdx, offset MsgBoxText
		mov	r8, offset MsgCaption
		xor	r9, r9		; MB_OK
		call	MessageBoxA
		xor	rcx, rcx
		call	ExitProcess	; выход
WinMain		endp
		end
