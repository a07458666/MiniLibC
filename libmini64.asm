
%macro gensys 2
	global sys_%2:function
sys_%2:
	push	r10
	mov	r10, rcx
	mov	rax, %1
	syscall
	pop	r10
	ret
%endmacro

; RDI, RSI, RDX, RCX, R8, R9

extern	errno

	section .data

	section .text

	gensys   0, read
	gensys   1, write
	gensys   2, open
	gensys   3, close
	gensys   9, mmap
	gensys  10, mprotect
	gensys  11, munmap
	gensys  13, rt_sigaction
	gensys  14, rt_sigprocmask
	gensys  22, pipe
	gensys  32, dup
	gensys  33, dup2
	gensys  34, pause
	gensys  35, nanosleep
	gensys  37, alarm
	gensys  57, fork
	gensys  60, exit
	gensys  79, getcwd
	gensys  80, chdir
	gensys  82, rename
	gensys  83, mkdir
	gensys  84, rmdir
	gensys  85, creat
	gensys  86, link
	gensys  88, unlink
	gensys  89, readlink
	gensys  90, chmod
	gensys  92, chown
	gensys  95, umask
	gensys  96, gettimeofday
	gensys 102, getuid
	gensys 104, getgid
	gensys 105, setuid
	gensys 106, setgid
	gensys 107, geteuid
	gensys 108, getegid
	gensys 127, rt_sigpending

	global open:function
open:
	call	sys_open
	cmp	rax, 0
	jge	open_success	; no error :)
open_error:
	neg	rax
%ifdef NASM
	mov	rdi, [rel errno wrt ..gotpc]
%else
	mov	rdi, [rel errno wrt ..gotpcrel]
%endif
	mov	[rdi], rax	; errno = -rax
	mov	rax, -1
	jmp	open_quit
open_success:
%ifdef NASM
	mov	rdi, [rel errno wrt ..gotpc]
%else
	mov	rdi, [rel errno wrt ..gotpcrel]
%endif
	mov	QWORD [rdi], 0	; errno = 0
open_quit:
	ret

	global sleep:function
sleep:
	sub	rsp, 32		; allocate timespec * 2
	mov	[rsp], rdi		; req.tv_sec
	mov	QWORD [rsp+8], 0	; req.tv_nsec
	mov	rdi, rsp	; rdi = req @ rsp
	lea	rsi, [rsp+16]	; rsi = rem @ rsp+16
	call	sys_nanosleep
	cmp	rax, 0
	jge	sleep_quit	; no error :)
sleep_error:
	neg	rax
	cmp	rax, 4		; rax == EINTR?
	jne	sleep_failed
sleep_interrupted:
	lea	rsi, [rsp+16]
	mov	rax, [rsi]	; return rem.tv_sec
	jmp	sleep_quit
sleep_failed:
	mov	rax, 0		; return 0 on error
sleep_quit:
	add	rsp, 32
	ret

	global sys_rt_sigreturn: function
sys_rt_sigreturn:
	mov rax, 15
	syscall

	global setjmp: function
setjmp:
	; rdi : jmp_buf env
	; save register
	mov QWORD [rdi + 0],  rbx ; save rbx to env[0]
	mov QWORD [rdi + 8],  rsp ; save rsp to env[1]
	mov QWORD [rdi + 16], rbp ; save rbp to env[2]
	mov QWORD [rdi + 24], r12 ; save r12 to env[3]
	mov QWORD [rdi + 32], r13 ; save r13 to env[4]
	mov QWORD [rdi + 40], r14 ; save r14 to env[5]
	mov QWORD [rdi + 48], r15 ; save r15 to env[6]
	mov rax, [rsp]            ; load return address to rax
	mov QWORD [rdi + 56], rax ; save rsp to env[7]
	
	; backup env
	push rdi   					; backup rdi (jmp_buf env)
	push rax					; allocate 8 byte
	
	; save sig mask 
	; sys_rt_sigprocmask(int how, const sigset_t *nset, sigset_t *oset, size_t sigsetsize);
	mov rdi, 0					; how = SIG_BLOCK = 0
	mov rsi, 0					; nset = NULL
	mov rdx, rsp				; oset = save to rsp (Stack top)
	mov rcx, 8					; sigsetsize long = 8
	call sys_rt_sigprocmask

	pop rax						; release stack 8 byte
	pop rdi						; restore env
	mov QWORD [rdi + 64], rsp	; from stack top (mask) to jmp_buf_s.mask

	mov rax, 0				  	; set reutn 0
	ret

	global longjmp: function
longjmp:
	; rdi : jmp_buf env
	; rsi : int val (return value)
	
	mov  rdx, [rdi + 64]		; set rdx = env.mask
	push rdi					; backup rdi (env)
	push rsi					; backup rsi (val)

	; set sig mask 
	; sys_rt_sigprocmask(int how, const sigset_t *nset, sigset_t *oset, size_t sigsetsize);
	mov rdi, 2					; how : SIG_SETMASK = 2
	mov QWORD rsi, rdx 			; nset = env.mask
	mov rdx, 0					; oset = NULL
	mov rcx, 8					; sigsetsize long = 8 byte
	call sys_rt_sigprocmask

	pop rsi						; restore env
	pop rdi						; restore val

	; load register
	mov QWORD rbx, [rdi + 0]
	mov QWORD rsp, [rdi + 8]
	mov QWORD rbp, [rdi + 16]
	mov QWORD r12, [rdi + 24]
	mov QWORD r13, [rdi + 32]
	mov QWORD r14, [rdi + 40]
	mov QWORD r15, [rdi + 48]
	mov QWORD rdx, [rdi + 56]
	
	mov     [rsp], rdx 		 ; set address to rsp
	mov       rax, rsi       ; return val(int)

	ret