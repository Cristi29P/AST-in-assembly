
section .data
    delim db " ", 0

section .bss
    root resd 1

section .text

extern check_atoi
extern print_tree_inorder
extern print_tree_preorder
extern evaluate_tree

extern malloc
extern strlen
extern strtok
extern strdup

my_strrev:
	enter 0, 0

	mov ebx, eax ; saving the initial address of eax
	mov eax, [esp + 8] ; getting the function argument

	push eax ; finding the string's length
	call strlen
	mov ecx, eax
	add esp ,4

	mov eax, ebx ; restoring the initial address

	push eax ; pushing on the stack the starting address

	mov esi, eax ; points to the start of the string
	add eax, ecx
	mov edi, eax ; points to the end of the string
	dec edi

	shr ecx, 1 ; finding the string's length / 2
	jz done ; we finished proccesing the string

reverser:
	;; series of interchanges
	mov al, [esi] 
	mov bl, [edi]
	mov [esi], bl 
	mov [edi], al
	       
	dec edi
	inc esi
	dec ecx

	jnz reverser

done:
	pop eax ; final result is in the eax register
	leave
	ret

global create_tree
global iocla_atoi

iocla_atoi:
	enter 0, 0

	;; making sure the registers are free
	xor eax, eax
	xor ebx, ebx
	xor edi, edi
	xor esi, esi
	mov edi, [esp + 8] ; saving the function's parameter

	cmp byte[edi], 45 ; checking if first character is a '-'
	jne looper ; jumping here if the number does not start with a '-'
	inc edi ; skipping the '-'
	inc esi ; setting the '-' flag

looper:
	mov bl, byte[edi]
	
	test ebx, ebx ; checking if we have reached the end of the string
	je finish

	sub ebx, 48 ; converting the character to number
	imul eax, 10 ; constructing the number
	add eax, ebx

	inc edi ; going to next character

	jmp looper

finish:
	cmp esi, 1 ; we are dealing with a negative number
	jne finish2 ; we are dealing with a positive number
	neg eax ; computing the two's complement


finish2:	
	leave   
    ret

create_tree:
    enter 0, 0

    ;; Saving the initial state of the registers
   	push ebx
   	push ecx
   	push edx
   	push edi
   	push esi
   	;; Making sure the registers are free
   	xor ebx, ebx
   	xor ecx, ecx
   	xor edx, edx
   	xor edi, edi
   	xor esi, esi

   	xor eax, eax
   	mov eax, [ebp + 8] ; Getting the function's parameter
   	push eax
   	call my_strrev

   	add esp, 4

   	;; First tokenization
   	push delim
   	push eax
   	call strtok
   	add esp, 8 


tokenizer: 
	cmp eax, 0 ; reached the end of the string
	je finish_token

	;; Reversing the string once again
	push eax
	call my_strrev
	add esp, 4

	;; Calculating the string's length
	push eax
	push eax
	call strlen
	add esp, 4

	mov edx, eax ; saving the length
	pop eax

	cmp edx, 1 ; checking if it's a number
	ja numar2

	cmp word[eax], 48 ; checking if it's a number
	jae numar2

	;; Number cheking failed => it must be an operator

	xor esi, esi
	xor edi, edi

	; pop two elements off the stack
	pop edi ; left operand
	pop esi ; right operand

	push eax
	call strdup ; allocate memory for the character
	add esp, 4

	xor ebx, ebx
	mov ebx, eax ; store the resulting address

	push 12
	call malloc ; allocate memory for the node
	add esp, 4

	mov [eax], ebx ; store the sign character address
	mov [eax + 4], edi ; store the address of the left operand
	mov [eax + 8], esi ; store the address of the right operand

	push eax ; push the resulting node

	jmp loop_end

numar2:
	push eax
	call strdup ; allocate memory for the number
	add esp, 4

	xor ebx, ebx
	mov ebx, eax ; store the resulting address

	push 4
	call malloc ; allocate heap space for the number
	add esp, 4

	mov [eax], ebx ; store the resulting address of strdup in the memory space allocated by malloc
	push eax ; push the resulting node

loop_end:
	;; tokenize again
	push delim
   	push 0
   	call strtok
   	add esp, 8

	jmp tokenizer

finish_token:
	pop eax

	; Restoring the registers' values
    pop esi
    pop edi
    pop edx
    pop ecx 
    pop ebx

    leave
    ret
