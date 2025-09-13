		includelib	kernel32.lib
		includelib	user32.lib
		extern	ExitProcess: proc
		extern  MessageBoxA: proc
		extern  wsprintfA: proc

.data
MsgCaption	db	"cpuid", 0
fmt		db	"Physical memory: 2^%d", 13, 10
		db	"Linear memory: 2^%d", 0
MsgBoxText	db	256 dup(0)

.code
WinMain		proc
		sub	rsp, 40		; выделить стек для передачи параметров + выравнивание
		xor	rdi, rdi	; обнуляем ответ
		xor	rsi, rsi	; обнуляем ответ
		mov	eax, 80000008h	; получить размер линейного (физического) адреса
		cpuid
		mov	dil, al		; ответ в rdi
		shr	rax, 8
		mov	sil, al		; ответ в rsi
fin:		; формирование строки с результатом
		mov	rcx, offset MsgBoxText
		mov	rdx, offset fmt
		mov	r8, rdi
		mov	r9, rsi
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
