.data
	prompt_size: .asciiz "Informe o tamanho maximo de elementos: "
	prompt_menu: .asciiz "\n======== MENU ======== \n1 - Adicionar elemento \n2 - Recuperar elemento \n3 - Imprimir lista \n4 - Deletar elemento \n5 - Sair\n======================"
	prompt_option: .asciiz "\nOpcao: "
	prompt_printlist: .asciiz "\n====== Elementos da Lista ======\n"
        prompt_value: .asciiz "\nValor: "
        prompt_position: .asciiz "\nPosicao: "
        prompt_added: .asciiz "\nElemento adicionado!"
        prompt_element: .asciiz "\nValor recuperado: "
        prompt_removed: .asciiz "\nElemento removido!"
        prompt_error1: .asciiz "\nErro: Lista cheia! Ignorando acao!"
        prompt_error2: .asciiz "\nErro: Indice invalido!"
        prompt_error3: .asciiz "\nErro: Lista vazia!"
        prompt_error4: .asciiz "\nErro: Opcao invalida! Tente novamente!"
        prompt_exit: .asciiz "\n==== Aplicacao Encerrada! ===="
        line: .asciiz "\n"
	memo: .word 8
.text 
	#Inicio da pilha em 0
	li $sp, 0
	#Posicao da memoria = s0
	li $s0, 0
	
	MAIN_FUNCTION:
		#Ler tamanho da lista
		la $a0, prompt_size
		jal PRINT_STR
		jal READ_INT
	
		#Adicionar na memoria
		sw $v0, memo($s0)
	
		#Atual
		addi $s0, $s0, 4
		li $s1, 0
		sw $s1, memo($s0)
		
		MENU:
			#Imprime linha vazia
			la $a0, line
			jal PRINT_STR
	
			#Imprimir menu de opcoes
			la $a0, prompt_menu
			jal PRINT_STR
	
			#Ler opcao do usuario
			la $a0, prompt_option
			jal PRINT_STR
			jal READ_INT
			move $s2, $v0 #Opcao = s2
			
			#Verificar opcao
			beq $s2, 1, ADD
			beq $s2, 2, RECOVER
			beq $s2, 3, PRINT
			beq $s2, 4, DEL
			beq $s2, 5, EXIT
		
			#Imprime mensagem de erro
			la $a0, prompt_error4
			jal PRINT_STR
			j MENU
			
		ADD:
			#Chama funcao de adicionar elemento
			jal ADD_ELEMENT			
			j MENU
				
		RECOVER:
			#Chama funcao de recuperar elemento
			jal RECOVER_ELEMENT
			j MENU
		
		PRINT:
			#Chama funcao de imprimir lista
			jal PRINT_LIST
			j MENU
		
		DEL:
			#Chama funcao de deletar elemento
			jal DELETE_ELEMENT
			j MENU

		EXIT:
			#Chama funcao de sair do programa
			jal EXIT_PROGRAM
		
#Adicionar elemento
ADD_ELEMENT:
	#Verificar tamanho atual
	li $s0, 0
	lw $s1, memo($s0)
	addi $s0, $s0, 4
	lw $s2, memo($s0)
	
	#Verificar se tamanho atual é igual ao tamanho máximo
	beq $s1, $s2, ALERT_ERROR1

	#Se o tamanho é menor que o máximo, adiciona elemento
	li $s0, 4
	lw $s1, memo($s0)
	li $s4, 0
	mul $s4, $s1, -4
	move $sp, $s4

	subu $sp, $sp, 4
	
	#Imprimir mensagem
	la $a0, prompt_value
	li $v0, 4
	syscall
	
	#Ler o valor digitado pelo usuário
	li $v0, 5
	syscall
	move $s1, $v0
	
	sw $s1, ($sp)
	
	#Imprimir mensagem de elemento adicionado
	la $a0, prompt_added
	li $v0, 4
	syscall
	
	move $a0, $s1
	
	#Incrementa valor atual	
	li $s0, 4
	lw $s1, memo($s0)
	addi $s1, $s1, 1
	sw $s1, memo($s0)
	
	#Retornar para o menu
	jr $ra
	
	#Imprimir mensagem de erro (lista cheia)
	ALERT_ERROR1:
		la $a0, prompt_error1
		li $v0, 4
		syscall
		
		#Retornar para o menu
		jr $ra

#Recuperar elemento
RECOVER_ELEMENT:
	#Reinicia pilha
	li $sp, 0
	
	#Imprimir mensagem
	la $a0, prompt_position
	li $v0, 4
	syscall
	
	#Ler elemento a ser recuperado
	li $v0, 5
	syscall
	move $s1, $v0
	
	#Verificar se indice e valido
	IF_RECOVER: #Valor invalido
		li $s0, 4
		lw $s2, memo($s0)
		bgt $s1, $s2, ALERT_ERROR2
		blez $s1, ALERT_ERROR2
	
	#Recuperar elemento
	ELSE_RECOVER: #Valor valido
		mul $s1, $s1, -4
		addu $sp, $sp, $s1
		lw $a1, ($sp)
			
		#Imprimir mensagem
		la $a0, prompt_element
		li $v0, 4
		syscall
		
		#Imprimeir valor recuperado
		move $a0, $a1	
		li $v0, 1
		syscall
		
		#Retornar para o menu
		jr $ra
		
	#Imprimir mensagem de erro
	ALERT_ERROR2:
		la $a0, prompt_error2
		li $v0, 4
		syscall
		
		#Retornar para o menu
		jr $ra

#Imprimir a lista
PRINT_LIST:
	#Reinicia pilha	
	li $s0, 4
	lw $s1, memo($s0)
	
	#Inicia valor
	li $sp, -4
	li $s3, 1
	
	#Verificar se lista esta vazia
	IF_PRINT: #Lista vazia
		blez  $s1, ALERT_ERROR3
	
	#Imprimir lista
	ELSE_PRINT: #Lista com elementos
		la $a0, prompt_printlist
		li $v0, 4
		syscall
		
		#Repetir até que todos os elementos sejam impressos
		FOR_LIST:
			#Verificar se todos os elementos foram impressos
			bgt $s3, $s1, EXIT_FOR_LIST
	
			#Imprimir elemento
			lw $t6, ($sp)
			move $a0, $t6
			li $v0, 1
			syscall
		
			la $a0, line
			li $v0, 4
			syscall
	
			#Voltar valor atual
			subu $sp, $sp, 4
			addi $s3, $s3, 1
			j FOR_LIST
		
		#Após imprimir todos, voltar ao menu
		EXIT_FOR_LIST:
			jr $ra
			
		#Mensagem de erro em caso de lista vazia
		ALERT_ERROR3:
			la $a0, prompt_error3
			li $v0, 4
			syscall
			
			#Retornar para o menu
			jr $ra

#Deletar elemento
DELETE_ELEMENT:
	#Imprimir mensagem
	la $a0, prompt_position
	li $v0, 4
	syscall
	
	#Ler posicao
	li $v0, 5
	syscall
	move $s1, $v0
	
	#Verificar se indice e valido
	IF_DELETE: #Valor invalido
		li $s0, 4
		lw $s2, memo($s0)
		bgt $s1, $s2, ALERT_ERROR4
		blez $s1, ALERT_ERROR4
	
	#Deletar elemento
	ELSE_DELETE: #Valor valido
		mul $sp, $s1, -4
		move $k0, $s1 
		addi $s5, $k0, 1
		move $k1, $s2
		
		#Reorganizar elementos
		FOR_DEL:
			bgt $k0, $k1, EXIT_FOR_DEL
			
			mul $sp, $s5, -4
			lw $s4, ($sp)
			
			mul $sp, $k0, -4
			sw $s4, ($sp)
				
			addi $k0, $k0, 1
			addi $s5, $s5, 1
			j FOR_DEL
		
		EXIT_FOR_DEL:
			#Retornar
			li $s0, 4
			lw $s1, memo($s0)
			subi $s1, $s1, 1
			sw $s1, memo($s0)
			
			#Imprimir mensagem
			la $a0, prompt_removed
			li $v0, 4
			syscall
			
			#Voltar para o menu
			jr $ra
		
		#Mensagem de erro	
		ALERT_ERROR4:
			la $a0, prompt_error2
			li $v0, 4
			syscall
			
			#Retornar para o menu
			jr $ra

#Imprimir string	
PRINT_STR:
	li $v0, 4
	syscall
	
	#Retornar para o menu
	jr $ra

#Ler inteiro	
READ_INT:
	li $v0, 5
	syscall
	
	#Retornar para o menu
	jr $ra

#Finaliza o programa	
EXIT_PROGRAM:
	la $a0, prompt_exit
	jal PRINT_STR

	li $v0, 10
	syscall 
	        
