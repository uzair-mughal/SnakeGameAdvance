INCLUDE irvine32.inc
.data
	
	codxy BYTE 2 DUP (0)
		  rowsize=$-codxy
		  BYTE 1776 DUP (0),0

	msg BYTE "WELCOME TO SNAKE GAME!!",0
	endmsg BYTE "Thanks for playing!!",0
	gameovermsg BYTE "Game Over!!",0
	scoremsg db "Score: ",0
    instruction1 BYTE "Use W , A , S , D to control your Snake",0
	instruction2 BYTE "Use esc anytime to quit",0
	instruction3 BYTE "Press Enter to start..",0
	row BYTE ?
	col BYTE ?
	heady BYTE ?
	headx BYTE ?
	len BYTE 1
	fruit BYTE "F",0
	foodx BYTE 38
	foody BYTE 12
	key BYTE  ?
	delaytime BYTE 200
	run BYTE 0

.code

instructions PROC

	mov dh,10
	mov dl,25
	
	call gotoxy
	mov edx,offset msg
	call WriteString

	mov dh,12
	mov dl,16
	
	call gotoxy
	mov edx,offset instruction1
	call WriteString

	mov dh,14
	mov dl,25
	
	call gotoxy
	mov edx,offset instruction2
	call WriteString

	mov dh,16
	mov dl,26
	
	call gotoxy
	mov edx,offset instruction3
	call WriteString

	call ReadInt
	call clrscr
	
	ret

instructions ENDP

draw PROC

	mov edx,0
	mov eax,0
	mov row,75
	mov col,25

	mov al,'#'
	movzx ecx,row
	L1:
		call WriteChar

	LOOP L1

	mov dh,0
	mov dl,0

	movzx ecx,col
	L2:
		call gotoxy
		call WriteChar
		inc dh

	LOOP L2

	mov dh,0
	mov dl,75

	movzx ecx,col
	L3:
		call gotoxy
		call WriteChar
		inc dh

	LOOP L3

	mov dh,25
	mov dl,0
	add row,1

	movzx ecx,row
	L4:
		call gotoxy
		call WriteChar
		inc dl

	LOOP L4

ret

draw ENDP

gameover PROC
	
	mov dh,12
	mov dl,33
	call gotoxy
	mov edx,offset gameovermsg
	call writestring
	call crlf
	mov dh,28
	mov dl,0
	call gotoxy
	exit

gameover ENDP

_read PROC
	
	mov eax,0
	call ReadKey
    jnz keybdpressed
    xor dl,dl
    ret

_read ENDP

keybdpressed PROC

    mov dl,al
    ret
 
keybdpressed ENDP

keyboard_function PROC
	
	call _read
	CMP dl, 0
	JE skip

	CMP dl,'w'
	JE _up
	CMP dl,'a'
	JE _left
	CMP dl,'s'
	JE _down
	CMP dl,'d'
	JE _right

	_up:
		
		mov al,key
		CMP al,'s'
		JE skip
		mov al,'w'
		mov key,al
		jmp skip

	_left:
		
		mov al,key
		CMP al,'d'
		JE skip
		mov al,'a'
		mov key,al
		jmp skip

	_down:
		
		mov al,key
		CMP al,'w'
		JE skip
		mov al,'s'
		mov key,al
		jmp skip

	_right:
		
		mov al,key
		CMP al,'a'
		JE skip
		mov al,'d'
		mov key,al
		jmp skip

	skip:

		ret

keyboard_function ENDP

movesnake_head PROC
	
	mov dl,headx
	mov dh,heady
	call gotoxy
	mov al,' '
	call WriteChar

		mov eax,0
		mov ebx,offset codxy
		add eax,rowsize
		mul len
		add ebx,eax
		mov esi,0

		cmp len,0
		JE down1

		movzx ecx,len
		L1:
			
			mov esi,0
			sub ebx,rowsize
			mov dh,[ebx+esi]
			inc esi
			mov dl,[ebx+esi]
			add ebx,rowsize
			mov esi,0
			mov [ebx+esi],dh
			inc esi
			mov [ebx+esi],dl
			
			sub ebx,rowsize

		LOOP L1

	down1:

	mov ebx,offset codxy
	mov esi,0

	CMP key,'w'
	JE _up
	CMP key,'a'
	JE _left
	CMP key,'s'
	JE _down
	CMP key,'d'
	JE _right
	 
	_up:
		
		dec dh
		CMP dh,0
		JE _gameover
		mov heady,dh
		mov [ebx+esi],dh
		inc esi
		mov [ebx+esi],dl
		jmp skip

	_left:
		
		dec dl
		CMP dl,0
		JE _gameover
		mov headx,dl
		mov [ebx+esi],dh
		inc esi
		mov [ebx+esi],dl
		jmp skip

	_down:
		
		inc dh
		CMP dh,25
		JE _gameover
		mov heady,dh
		mov [ebx+esi],dh
		inc esi
		mov [ebx+esi],dl
		jmp skip

	_right:

		inc dl
		CMP dl,75
		JE _gameover
		mov headx,dl
		mov [ebx+esi],dh
		inc esi
		mov [ebx+esi],dl
		jmp skip

	skip:
		
		call gotoxy
		mov al,'o'
		call WriteChar

		down:
		ret
	
	_gameover:

		call gameover
		ret
	
movesnake_head ENDP

check_hit_body_fuc PROC
	
	mov eax,0
	mov ebx,offset codxy
	mov eax,rowsize
	add ebx,eax
	mov esi,0

	movzx ecx,len
	L1:
		mov al,heady
		cmp [ebx+esi],al
		JE check
		jmp down

		check:

			inc esi
			mov al,headx
			cmp [ebx+esi],al
			JE truecase
			jmp down

		truecase:
			
			call gameover

		down:
			
			add ebx,rowsize
			mov esi,0
	
	LOOP L1

	ret

check_hit_body_fuc ENDP

print_body_fun PROC
	
	mov ebx,offset codxy
	mov eax,rowsize
	add ebx,eax

	cmp len,0
	JE down

	movzx ecx,len
	L1:
		
		mov esi,0
		mov dh,[ebx+esi]
		inc esi
		mov dl,[ebx+esi]
		call gotoxy
		mov al,'x'
		call WriteChar
		add ebx,rowsize
		
	LOOP L1

	down:

	mov ebx,offset codxy
	mov eax,rowsize
	mul len
	add ebx,eax
	mov esi,0

	mov dh,[ebx+esi]
	inc esi
	mov dl,[ebx+esi]
	call gotoxy
	mov al,' '
	call WriteChar
	ret

print_body_fun ENDP

check_eat_food PROC
	
	mov al,heady
	CMP foody,al
	JE check
	jmp skip
	
	check:
		
		mov al,headx
		CMP foodx,al
		JE truecase
		jmp skip
	
	truecase:
		
		inc len
		
	skip:

		ret

check_eat_food ENDP

generate_fruit PROC
	
	CMP run,40
	JNE down

	mov dh, foody
	mov dl, foodx
	mov al, ' '
	call gotoxy
	call writechar 

	L1:

	mov eax,0
	call randomize
	mov al,23
	call randomrange
	mov dh,al
	mov al,73
	call randomrange
	mov dl,al

	add dl,1
	add dh,1

	call gotoxy
	mov al,fruit
	call WriteChar
	mov run,0
	
	mov foodx, dl
	mov foody, dh

	down:
		
		inc run
		ret

generate_fruit ENDP

startgame PROC
	
	call ReadChar
	

	mov heady,12
	mov headx,37
	mov dh,heady
	mov dl,headx
	mov [codxy+0],dh
	mov [codxy+1],dl
	
	mov key,al

	_while:
		
		movzx eax,delaytime
		call delay
		call movesnake_head
		call check_hit_body_fuc
		call print_body_fun
		call check_eat_food
		call keyboard_function
		call generate_fruit
		mov dl,headx
		mov dh,heady
		call gotoxy

	jmp _while

	ret

startgame ENDP

main PROC
call draw
call instructions
call draw
call startgame

mov dh,28
mov dl,0
call gotoxy
exit
main ENDP


END main