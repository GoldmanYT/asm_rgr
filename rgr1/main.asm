		includelib	kernel32.lib
		includelib	user32.lib
		extern	ExitProcess: proc
		extern  MessageBoxA: proc
		extern  wsprintfA: proc

.data
s1		db	13 dup(0)	; vendor id
s2		db	50 dup(0)	; brand string
s3		db	"Brand string not supported", 0
MsgCaption	db	"cpuid", 0
fmt		db	"Vendor ID: %s", 13, 10
		db	"CPU: %s", 0
MsgBoxText	db	256 dup(0)

.code
WinMain		proc
		sub	rsp, 5 * 8	; выделить стек для передачи пара-метров + выравнивание
		xor	rax, rax	; eax=0
		lea	rdi, s1
		cpuid			; получить vendor id
		mov	[rdi], ebx	; сохранить его в
		mov	[rdi+4],edx 	; строку
		mov	[rdi+8],ecx
		lea	rsi,s3		; изначально запоминаем указатель s3
		mov	eax,80000000h	; проверка поддержки brand string
		cpuid			; получить информацию
		test	eax,80000000h	; если не поддерживается
		jz	fin		; то перейти
		cmp	eax,80000004h	; или если поддерживается не полностью
		jb	fin 		; то перейти
		mov	eax,80000002h 	; получить первую часть
		cpuid 			; brand string
		lea	rdi, s2
		mov	[rdi],eax 	; сохранить
		mov	[rdi+4],ebx 	; ее
		mov	[rdi+8],ecx 	; в строку
		mov	[rdi+12],edx
		mov	eax,80000003h 	; получить вторую часть
		cpuid			; brand string
		mov	[rdi+16],eax 	; сохранить
		mov	[rdi+20],ebx 	; ее
		mov	[rdi+24],ecx 	; в строку
		mov	[rdi+28],edx
		mov	eax,80000004h ;получить третью часть
		cpuid ;brand string
		mov	[rdi+32],eax ;сохранить
		mov	[rdi+36],ebx ;ее
		mov	[rdi+40],ecx ;в строку
		mov	[rdi+44],edx
		lea	rsi,s2 ;указатель на brand string
fin:		; формирование строки с результатом
		mov	rcx,offset MsgBoxText
		mov	rdx,offset fmt
		mov	r8,offset s1
		mov	r9,rsi
		call	wsprintfA
		; вывод результата
		xor	rcx,rcx
		mov	rdx,offset MsgBoxText
		mov	r8,offset MsgCaption
		mov	r9,0 ;MB_OK
		call	MessageBoxA
		xor	rcx,rcx
		call	ExitProcess	; выход
WinMain		endp
		end
