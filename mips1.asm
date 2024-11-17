.data 
k: .word 2                 # k = número de vizinhos
h: .word 3                 # h = até quantos dias depois se deseja prever
w: .word 2                 # w = números de dias que basea a análise
tam: .word 10              # Tamanho do conjunto de dados
xTrain: .double 5727.99, 5635.07, 5599.42, 5567.89, 5530.23, 5457.2, 5413.43, 5532.47, 5503.79, 5634.86
msg_x:  .asciiz "Matrix x:\n"
msg_y:  .asciiz "Vector y:\n"
newline: .asciiz "\n"
space:  .asciiz " "

.text
.globl main
main:
    # Carrega os parâmetros
    la $t1, k
    la $t2, h
    la $t3, w
    la $t4, tam
    lw $s0, 0($t1)            
    lw $s1, 0($t2)             
    lw $s2, 0($t3)             
    lw $t0, 0($t4)            
    la $t1, xTrain          # Endereço base de xTrain

    # Calcula o número de linhas do array y
    sub $t2, $t0, $s2       
    sub $t2, $t2, $s1       
    addi $t2, $t2, 1	#linhas_y = tam - w - h + 1
    subi $sp, $sp, 4
    sw $t2, 0($sp) # Armazena na pilha linhas_y
    # Checa se o número de linhas é válido
    blez $t2, done          # Se não houver linhas, finaliza
    # Aloca espaço para o vetor y
    sll $t2, $t2, 3         # Multiplica por 8 (tamanho do double)
    sll $t0, $t0, 3         # Tamanho real do conjunto de dados
    subi $sp, $sp, 4
    sw $t0, 0($sp)
    li $v0, 9               # syscall para alocação dinâmica do array
    add $a0, $zero, $t2
    syscall
    move $s5, $v0           # $s5 = base de y

    # Aloca espaço para x_train
    mul $t3, $t2, $s2       # espaço necessário para x_train = (linhas_y * 8) * w
    li $v0, 9               
    add $a0, $zero, $t3
    syscall
    move $s6, $v0           # $s6 = base de x_train

    # Chama a função fx_train
    move $a0, $s6           # base x_train
    move $a1, $s5           # base y
    move $a2, $t1           # xTrain (conjunto de dados originais)
    move $a3, $s1           # h
    subi $sp, $sp, 4
    sw $s2, 0($sp) # w
    jal fx_train # treina modelo KNN
    move $s6, $v0 # Retorna x_train
    move $s5, $v1 # Retorna y
    # Imprime a matriz y
    li $v0, 4                # syscall para print_string
    la $a0, msg_y            
    syscall

    la $t0, tam
    lw $t0, 0($t0)
    sub $t0, $t0, $s1
    sub $t0, $t0, $s2 
    addi $t0, $t0, 1 # linhas_y = tam - h - w + 1
    move $a0, $t0 # linhas_y
    addi $a1, $zero, 1 # colunas = 1
    move $a2, $s5 # base da matriz y
    jal print_matrix # imprime matriz y
    
    # Imprime matriz x_train
    li $v0, 4
    la $a0, msg_x
    syscall
    
    move $a0, $t0 # linhas_y
    move $a1, $s2 # colunas = w
    move $a2, $s6 # base x_train
    jal print_matrix
    j done
    
print_matrix:
	add $t1, $zero, $zero #linha
	l1:
		add $t2, $zero, $zero #coluna
		l2:
			mul $t3, $t1, $a1 # i * w
			add $t3, $t3, $t2 # (i * w) + j
			sll $t3, $t3, 3 # deslocamento real (double)
			add $t3, $t3, $a2 # a[i][j]
			l.d $f12, 0($t3)
			li $v0, 3 # imprime double
			syscall
			move $t3, $a0
			li $v0, 4
			la $a0, space # imprime space
			syscall
			move $a0, $t3
			addi $t2, $t2, 1 # j++
			slt $t3, $t2, $a1 # j < colunas
			bne $t3, $zero, l2
			
		move $t3, $a0
		li $v0, 4
		la $a0, newline # imprime new_line
		syscall
		move $a0, $t3
		addi $t1, $t1, 1 #i++
		slt $t3, $t1, $a0 #i < linhas
		bne $t3, $zero, l1
	jr $ra #encerra rotina
				 		
done:
    li $v0, 10               # syscall para exit
    syscall

fx_train: # função para treinar o modelo KNN
    
    lw $t1, 0($sp) #w
    lw $t2, 4($sp) #tam
    lw $t3, 8($sp) #tam_y
    move $t0, $zero #linha i
    LOOP:
    	move $t4, $zero # coluna j
    	x_loop:
    		add $t5, $zero, $t0 # i => posição de x_train_original
    		mul $t7, $t0, $t1 # i * w => posição de x_train_new
    		add $t5, $t5, $t4 # i + j
    		add $t7, $t7, $t4 # (i * w) + j
    		sll $t7, $t7, 3
    		sll $t5, $t5, 3
    		add $t6, $a2, $t5 #x_train_original[i][j]
    		add $t7, $a0, $t7 #x_train_new[i][j]
    		l.d $f12, 0($t6)
    		s.d $f12, 0($t7) # Armazena o valor do dia no conjunto novo
    		addi $t4, $t4, 1 #j++
    		slt $t5, $t4, $t1 # j < w
    		bne $t5, $zero, x_loop
    	add $t5, $t0, $t1 # i + w
    	add $t5, $t5, $a3 # i + w + h
    	subi $t5, $t5, 1 # i + w + h - 1 => dia da previsão de Y[i] = X_train_original[i][j]
    	sll $t5, $t5, 3
    	add $t5, $a2, $t5
    	l.d $f12, 0($t5)         # Carrega de x_train_original
    	add $t5, $zero, $t0
    	sll $t5, $t5, 3
    	add $t5, $a1, $t5
    	s.d $f12, 0($t5)         # Armazena a previsão em Y[i]        
    	addi $t0, $t0, 1         # i++
    	lw $t3, 8($sp)
    	slt $t5, $t0, $t3        # i < tam_y
    	bne $t5, $zero, LOOP
    	addi $sp, $sp, 12 #restaura a pilha de execução
    	move $v0, $a0 # x_train_new
    	move $v1, $a1# y
    	jr $ra