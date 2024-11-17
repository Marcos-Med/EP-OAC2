.data 
const: .double 999999999.9999
buffer:             .space 256        # Buffer para leitura de linhas
k: .word 2                 # k = número de vizinhos
h: .word 1                 # h = até quantos dias depois se deseja prever
w: .word 3                 # w = números de dias que basea a análise
contador_linha:     .word 0 #número de linhas do arquivo original
nome_arquivo:       .asciiz "C:\\Users\\Usuario\\Documents\\USP\\4_SEMESTRE\\OAC2\\EP1\\x_train.txt"
nome_outro:         .asciiz "C:\\Users\\Usuario\\Documents\\USP\\4_SEMESTRE\\OAC2\\EP1\\x_test.txt"
output:         .asciiz "C:\\Users\\Usuario\\Documents\\USP\\4_SEMESTRE\\OAC2\\EP1\\y_pred.txt"
output_teste:   .asciiz "C:\\Users\\Usuario\\Documents\\USP\\4_SEMESTRE\\OAC2\\EP1\\y_test.txt"
msg_x:  .asciiz "Matrix x:\n"
msg_y:  .asciiz "Vector y:\n"
newline: .asciiz "\n"
space:  .asciiz " "
# Definição dos valores de ponto flutuante (agora como double)
double_zero:         .double 0.0
double_um:           .double 1.0
double_dez:          .double 10.0


.text
.globl main
main:
# Chamada da função leitura_arquivo com x_train
    la      $a0, nome_arquivo      # Ponteiro para o nome do arquivo
    jal     leitura_arquivo         # Chama leitura_arquivo
    move    $s1, $v0 #vetor base x_train
    la $t6, contador_linha
    lw $t6, 0($t6)# linhas de x_train
    subi $sp, $sp, 4
    sw $t6, 0($sp)
    
    # Chamada da função leitura_arquivo com x_teste
    la      $a0, nome_outro       
    jal     leitura_arquivo       
    move    $t8, $v0 # vetor base x_teste
    la $t7, contador_linha 
    lw $t7, 0($t7) #linhas de x_teste
    subi $sp, $sp, 4
    sw $t7, 0($sp)
## Treinamento do Modelo KNN
    # Carrega os parâmetros
    la $t1, k
    la $t2, h
    la $t3, w
    lw $s0, 0($t1)#k
    add $t1, $zero, $s1 #Endereço base de x_train original           
    lw $s1, 0($t2)#h             
    lw $s2, 0($t3)#w             
    lw $t0, 4($sp) #linhas de x_train original
    
    # Calcula o número de linhas do array y_train
    sub $t2, $t0, $s2  # tam - w     
    sub $t2, $t2, $s1 # tam - w - h      
    addi $t2, $t2, 1	#linhas_y-train = tam - w - h + 1
    # Checa se o número de linhas é válido
    blez $t2, done          # Se não houver linhas, finaliza
    # Aloca espaço para o vetor y_train
    sll $t2, $t2, 3         # Multiplica por 8 (tamanho do double)
    sll $t0, $t0, 3         # Tamanho real do conjunto de dados x_train
    li $v0, 9               # syscall para alocação dinâmica do array
    add $a0, $zero, $t2
    syscall
    move $s5, $v0           # $s5 = base de y_train
    
    # Checa se o número de linhas é válido
    blez $t2, done          # Se não houver linhas, finaliza
    # Aloca espaço para x_train
    mul $t3, $t2, $s2       # espaço necessário para x_train = (linhas_y * 8) * w
    li $v0, 9               
    add $a0, $zero, $t3
    syscall
    move $s6, $v0           # $s6 = base de x_train
    
    lw $t0, 4($sp) #linhas de x_train original
    # Calcula o número de linhas do array y_train
    sub $t2, $t0, $s2  # tam - w     
    sub $t2, $t2, $s1 # tam - w - h      
    addi $t2, $t2, 1	#linhas_y-train = tam - w - h + 1
    
    # Chama a função fx_train -> x_train
    move $a0, $s6           # base x_train
    move $a1, $s5           # base y_train
    move $a2, $t1           # x_Train (conjunto de dados originais)
    move $a3, $s1           # h
    subi $sp, $sp, 8
    sw $s2, 4($sp) # w
    sw $t2, 0($sp) #linhas
    jal fx_train # treina modelo KNN
    move $s6, $v0 # Retorna x_train treinado
    move $s5, $v1 # Retorna y_train treinado
    
    lw $t0, 4($sp) #linhas de x_teste original
    # Calcula o número de linhas do array y
    sub $t2, $t0, $s2  # tam - w     
    sub $t2, $t2, $s1  # tam - w - h     
    addi $t2, $t2, 1	#linhas_y-teste = tam - w - h + 1
          
    lw $t0, 0($sp) #linhas de x_teste original
    # Calcula o número de linhas do array y
    sub $t2, $t0, $s2  # tam - w     
    sub $t2, $t2, $s1  # tam - w - h     
    addi $t2, $t2, 1	#linhas_y-teste = tam - w - h + 1
   # Checa se o número de linhas é válido
    blez $t2, done          # Se não houver linhas, finaliza
    # Aloca espaço para o vetor y
    sll $t2, $t2, 3         # Multiplica por 8 (tamanho do double)
    sll $t0, $t0, 3         # Tamanho real do conjunto de dados
    li $v0, 9               # syscall para alocação dinâmica do array
    add $a0, $zero, $t2
    syscall
    move $t5, $v0           # $s5 = base de y_teste
    
    # Aloca espaço para x_train
    mul $t3, $t2, $s2       # espaço necessário para x_train = (linhas_y * 8) * w
    li $v0, 9               
    add $a0, $zero, $t3
    syscall
    move $t9, $v0           # $s6 = base de x_teste
    
    
    lw $t0, 0($sp) #linhas de x_teste original
    # Calcula o número de linhas do array y
    sub $t2, $t0, $s2  # tam - w     
    sub $t2, $t2, $s1  # tam - w - h     
    addi $t2, $t2, 1	#linhas_y-teste = tam - w - h + 1
    
      # Chama a função fx_train -> x_teste
    move $a0, $t9           # base x_teste
    move $a1, $t5           # base y_teste
    move $a2, $t8           # x_teste (conjunto de dados originais)
    move $a3, $s1           # h
    subi $sp, $sp, 8
    sw $s2, 4($sp) # w
    sw $t2, 0($sp)# linhas
    jal fx_train # treina modelo KNN
    move $t9, $v0 # Retorna x_teste
    move $t5, $v1 # Retorna y_teste
    
    
    la $t1, k
    la $t4, h
    la $t3, w
    lw $s0, 0($t1)  #k          
    lw $s1, 0($t4)  #h           
    lw $s2, 0($t3)  #w           
    
    move $s3, $t9 #x_teste treinado
    move $s4, $s6 #x_train treinado
    
    
    lw $t0, 0($sp)
    # Calcula o número de linhas do array y
    sub $t2, $t0, $s2       
    sub $t2, $t2, $s1       
    addi $t2, $t2, 1	#linhas_y-pred = tam - w - h + 1

    # Aloca espaço para y_pred
    sll $t3, $t2, 3
    li $v0, 9               
    add $a0, $zero, $t3
    syscall
    move $s6, $v0           # $s6 = base de y_pred
    
    #Vetor auxiliar de distância
    lw $t0, 4($sp) #x_train
    sub $t2, $t0, $s2       
    sub $t2, $t2, $s1       
    addi $t2, $t2, 1
    sll $t3, $t2, 3 #vetor xtrain
    li $v0, 9               
    add $a0, $zero, $t3
    syscall
    move $s7, $v0           # $s7 = base de distância
    
    lw $t0, 4($sp)
    sub $t2, $t0, $s2       
    sub $t2, $t2, $s1       
    addi $t2, $t2, 1	#linhas train = tam - w - h + 1
    lw $t0, 0($sp)
    sub $t0, $t0, $s2
    sub $t0, $t0, $s1
    addi $t0, $t0, 1 #teste
    addi $sp, $sp, 4
     
   
	sll $t4, $s0, 3
	li $v0, 9
	add $a0, $zero, $t4
	syscall
	move $t8, $v0 #vetor auxiliar de dist (k)
	li $t1, 0
	la $t3, const #infinity
	l.d $f0, 0($t3)
	loop: #Preenche com valores infinity
		sll $t4, $t1, 3
		add $t4, $t4, $t8
		s.d $f0, 0 ($t4)
		addi $t1, $t1, 1
		slt $t4, $t1, $s0
		bne $t4, $zero, loop
	sll $t4, $s0, 3
	li $v0, 9
	add $a0, $zero, $t4
	syscall
	move $t9, $v0#vetor auxiliar de valor(k)
	
     subi $sp, $sp, 4
     sw $t5, 0($sp)	
     k_vizinhos:
     	   li $t1, 0 #i -> teste
     	   K1:
     	        move $a0, $t1
     	        subi $sp, $sp, 4
     	        sw   $t1, 0($sp)
     	        move $a1, $s7
     	        jal dist
     	        move $s7, $v0
     	        lw   $t1, 0($sp)
     	        addi $sp, $sp, 4
     	   	li $t3, 0 #j -> train 
     	   	K2:
     	   	    add $t4, $zero, $t3
     	   	    sll $t4, $t4, 3
     	   	    add $t4, $t4, $s7
     	   	    l.d $f0, 0($t4) #distância entre i-teste e j-train
     	   	    sll $t4, $t3, 3
     	   	    add $t4, $t4, $s5
     	   	    l.d $f2, 0($t4) #valor de y_train[j]
     	   	    j less_than
     	   	    return:
     	   	    addi $t3, $t3, 1
     	   	    slt $t4, $t3, $t2 #train
     	   	    bne $t4, $zero, K2
     	   	 li $t4, 0
     	   	 mtc1 $t4, $f2
     	   	 cvt.d.w $f2, $f2 #valor zero em double
     	   	 sum: #realiza o somátorio dos k vizinhos 	  
     	   	 	sll $t5, $t4, 3
     	   	 	add $t5, $t5, $t9
     	   	 	l.d $f0, 0($t5)
     	   	 	add.d $f2, $f2, $f0
     	   	 	addi $t4, $t4, 1
     	   	 	slt $t5, $t4, $s0 # z < k
     	   	 	bne $t5, $zero, sum
     	   	 mtc1 $s0, $f0
     	   	 cvt.d.w $f0, $f0 #k em double
     	   	 div.d $f2, $f2, $f0 # previsão através da média dos k vizinhos
     	   	 sll $t4, $t1, 3
     	   	 add $t4, $t4, $s6
     	   	 s.d $f2, 0($t4) #Armazena a média
	la $t4, const
	l.d $f0, 0($t4)
	li $t4, 0
	loop_2: #Reinicia com infinity
		sll $t6, $t4, 3
		add $t6, $t6, $t8
		s.d $f0, 0 ($t6)
		addi $t4, $t4, 1
		slt $t6, $t4, $s0
		bne $t6, $zero, loop_2
     	 addi $t1, $t1, 1
     	 slt $t4, $t1, $t0 #teste
     	 bne $t4, $zero, K1
    la $a0, output
    move $a1, $s6
    move $a2, $t0
    jal saida
    lw $t5, 0($sp)
    addi $sp, $sp, 4
    #move $a0, $t0
    #li $a1, 1
    #move $a2, $s6
    #jal print_matrix
    la $a0, output_teste
    move $a1, $t5
    move $a2, $t0
    jal saida
    j done
    
 dist:
	  li $t1, 0 #i -> train
	  L1:
	     li $t4, 0
	     mtc1 $t4, $f4
	     cvt.d.w $f4, $f4
	     li $t3, 0 #j
	  	L2:
	     	   mul $t4, $t1, $s2 #i*w
	           add $t4, $t4, $t3 #[i][j]
	           sll $t4, $t4, 3
	           add $t5, $t4, $s4 #x_train[i][j]
	           l.d $f2, 0($t5) #x_train
	           mul $t4, $a0, $s2 #k*w
	           add $t4, $t4, $t3#[k][j]
	           sll $t4, $t4, 3
	           add $t5, $t4, $s3 #x_teste[k][j]
	           l.d $f0, 0($t5)
	           sub.d $f0, $f0, $f2 #(x1-x2)
	           mul.d $f0, $f0, $f0 #(x1-x2)^2
	           add.d $f4, $f4, $f0 #distância
	           addi $t3, $t3, 1 #j++
	           slt $t4, $t3, $s2 # j < w
	           bne $t4, $zero, L2
	       add $t4, $zero, $t1
	       sll $t4, $t4, 3
	       add $t4, $t4, $a1 #dist[k][i]
	       s.d $f4, 0($t4)#dist
	       addi $t1, $t1, 1#i++
	       slt $t4, $t1, $t2 # i < linhas_train
	       bne $t4, $zero, L1
    move $v0, $a1
    jr $ra
 less_than:
 	la $t4, const
	l.d $f8, 0($t4)
	add $t4, $zero, $zero
 	check_infinity:
 	        beq $t4, $s0, replace_max
 	        sll $t7, $t4, 3
 	        add $t7, $t7, $t8
 	        l.d $f6, 0($t7)
 	        c.eq.d $f6, $f8 #infinito
 	        move $t5, $t4
 	        bc1t insert
 	        addi $t4, $t4, 1
 	        j check_infinity
 	 replace_max:
 	 	subi $t7, $s0, 1
 	 	sll $t7, $t7, 3
 	 	add $t7, $t7, $t8
 	 	l.d $f6, 0($t7)
 	 	c.lt.d $f0, $f6
 	 	move $t5, $s0
 	 	subi $t5, $t5, 1
 	 	bc1t insert
 	 	j return
 	 insert:
 	 	sll $t7, $t5, 3
 	 	add $t7, $t7, $t8
 	 	s.d $f0, 0($t7) #insere
 	 	sll $t7, $t5, 3
 	 	add $t7, $t7, $t9
 	 	s.d $f2, 0($t7)
 	 	add $t4, $zero, $zero
 	 	move $t6, $s0
 	 	bubble_sort:
 	 		subi $t6, $t6, 1
 	 		beq $t6, $zero, return
 	 	sort_loop:
 	 		beq $t4, $t6, bubble_sort
 	 		sll $t7, $t4, 3
 	 		add $t7, $t7, $t8
 	 		l.d $f14, 0($t7)
 	 		l.d $f16, 8($t7)
 	 		sll $t7, $t4, 3
 	 		add $t7, $t7, $t9
 	 		l.d $f18, 0($t7)
 	 		l.d $f20, 8($t7)
 	 		c.le.d $f14, $f16
 	 		bc1t next_elem
 	 		sll $t7, $t4, 3
 	 		add $t7, $t7, $t8
 	 		s.d $f16, 0($t7)
 	 		s.d $f14, 8($t7)
 	 		sll $t7, $t4, 3
 	 		add $t7, $t7, $t9
 	 		s.d $f20, 0($t7)
 	 		s.d $f18, 8($t7)
 	 	next_elem:
 	 		addi $t4, $t4, 1
 	 		j sort_loop
  
# Função leitura_arquivo
leitura_arquivo:
    # Início da função
    addi    $sp, $sp, -32
    sw      $ra, 28($sp)
    sw      $s0, 24($sp)
    sw      $s1, 20($sp)
    sw      $s2, 16($sp)
    sw      $s3, 12($sp)
    sw      $s4, 8($sp)
    sw      $s5, 4($sp)
    sw      $s6, 0($sp)
    move    $s2, $a0              # Salvar $a0 (nome do arquivo) em $s2

    # Chama a função tratar_arquivo
    jal     tratar_arquivo          # Chama tratar_arquivo
    # Epílogo da função
    lw      $s6, 0($sp)
    lw      $s5, 4($sp)
    lw      $s4, 8($sp)
    lw      $s3, 12($sp)
    lw      $s2, 16($sp)
    lw      $s1, 20($sp)
    lw      $s0, 24($sp)
    lw      $ra, 28($sp)
    addi    $sp, $sp, 32
    jr      $ra                     # Retorna para o chamador (main)

# Função tratar_arquivo
tratar_arquivo:
    # 1 - Abrir o arquivo cujo nome está em $s2
    move    $a0, $s2              # Usa o nome do arquivo passado
    li      $a1, 0                # Modo de leitura
    li      $v0, 13               # Syscall para abrir arquivo
    syscall
    move    $s0, $v0              # $s0 = descritor de arquivo

    # 2 - Contar o número de linhas no arquivo
    li      $t0, 0                 # Contador de linhas

loop_contador_linhas:
    # Ler um byte do arquivo
    move    $a0, $s0               # Descritor de arquivo
    la      $a1, buffer            # Buffer para leitura
    li      $a2, 1                 # Ler 1 byte
    li      $v0, 14                # Syscall para ler do arquivo
    syscall
    beqz    $v0, fim_contador_linhas   # EOF alcançado
    lb      $t1, 0($a1)            # Carregar o byte lido
    li      $t2, 10                # Código ASCII para '\n'
    beq     $t1, $t2, incremento_contador_linhas
    j       loop_contador_linhas

incremento_contador_linhas:
    addi    $t0, $t0, 1            # Incrementar contador de linhas
    j       loop_contador_linhas

fim_contador_linhas:
    # Verificar se o último caractere não foi uma nova linha
    bne     $t1, $t2, incremento_contador_linhas_fim
    sw      $t0, contador_linha    # Armazenar contador de linhas
    j       alocar_vetor

incremento_contador_linhas_fim:
    # Se o arquivo não terminar com '\n', incrementa o contador
    addi    $t0, $t0, 1
    sw      $t0, contador_linha

alocar_vetor:
    # 3 - Criar um vetor com o tamanho da quantidade de linhas
    # Calcular o tamanho necessário para o vetor
    lw      $t0, contador_linha
    li      $t1, 8                 # Tamanho de double em bytes
    mul     $t2, $t0, $t1          # Tamanho total = num_linhas * 8

    # Alocar memória para o vetor
    move    $a0, $t2               # Tamanho para alocar
    li      $v0, 9                 # Syscall para sbrk (alocação de memória)
    syscall
    move    $s1, $v0               # Ponteiro para o vetor numbers

apos_contar_linhas:
    # Fechar o arquivo para reposicionar o ponteiro
    move    $a0, $s0
    li      $v0, 16                # Syscall para fechar arquivo
    syscall

    # Reabrir o arquivo para leitura novamente usando $s2
    move    $a0, $s2              # Usa o nome do arquivo salvo em $s2
    li      $a1, 0                # Modo de leitura
    li      $v0, 13               # Syscall para abrir arquivo
    syscall
    move    $s0, $v0              # $s0 = descritor de arquivo

    # 4 - Loop de 0 até a quantidade de linhas
    li      $t3, 0                 # Índice da linha atual

loop_processar_linhas:
    lw      $t0, contador_linha
    bge     $t3, $t0, fim_processamento_linha

    # 5 - Ler cada linha até encontrar '\n'
    # Inicializar índice do buffer
    li      $t4, 0                 # Índice do buffer

loop_ler_linhas:
    move    $a0, $s0
    la      $a1, buffer
    add     $a1, $a1, $t4          # $a1 = buffer + $t4
    li      $a2, 1
    li      $v0, 14                # Syscall para ler do arquivo
    syscall
    beqz    $v0, fim_da_linha      # EOF alcançado
    lb      $t5, 0($a1)
    li      $t6, 10                # '\n'
    beq     $t5, $t6, fim_da_linha
    addi    $t4, $t4, 1            # Incrementar índice do buffer
    j       loop_ler_linhas

fim_da_linha:
    # Adicionar terminador nulo ao buffer
    la      $a1, buffer
    add     $a1, $a1, $t4
    sb      $zero, 0($a1)

    # 6 - Inicializar um double com 0.0
    la      $t0, double_zero
    l.d     $f0, 0($t0)            # num = 0.0
    li      $t7, 0                 # Índice do buffer
    li      $t8, 0                 # decimal_point_passed = 0
    la      $t0, double_um
    l.d     $f2, 0($t0)            # decimal_divider = 1.0

    # Inicializar sum_ascii = 0.0
    la      $t0, double_zero
    l.d     $f6, 0($t0)            # sum_ascii = 0.0

loop_processar_caractere:
    la      $a1, buffer
    add     $a1, $a1, $t7          # $a1 = buffer + $t7
    lb      $t9, 0($a1)
    beqz    $t9, armazena_numero   # Fim da string

    # Converter código ASCII para double e somar ao registrador
    mtc1    $t9, $f8               # Move ASCII code to $f8 (lower 32 bits)
    cvt.d.w $f8, $f8               # Convert to double
    add.d   $f6, $f6, $f8          # sum_ascii += ASCII code

    # 7 - Verificar se o caractere é dígito ou '.'
    li      $t6, 46                # '.' em ASCII
    beq     $t9, $t6, flag_casa_decimal
    li      $t0, 48                # '0' em ASCII
    li      $t1, 57                # '9' em ASCII
    blt     $t9, $t0, proximo_caractere
    bgt     $t9, $t1, proximo_caractere

    # 8 - Construir o número
    sub     $t2, $t9, 48           # Converter caractere para dígito
    mtc1    $t2, $f4               # Move digit to $f4
    cvt.d.w $f4, $f4               # Convert to double

    beqz    $t8, antes_casa_decimal

depois_casa_decimal:
    # decimal_divider *= 10
    la      $t0, double_dez
    l.d     $f10, 0($t0)           # Load 10.0 into $f10
    mul.d   $f2, $f2, $f10         # decimal_divider *= 10
    # num += digit / decimal_divider
    div.d   $f8, $f4, $f2
    add.d   $f0, $f0, $f8          # num += $f8
    j       incrementa_indice_caractere

antes_casa_decimal:
    # num = num * 10
    la      $t0, double_dez
    l.d     $f10, 0($t0)           # Load 10.0 into $f10
    mul.d   $f0, $f0, $f10         # num = num * 10
    # num += digit
    add.d   $f0, $f0, $f4          # num += digit
    j       incrementa_indice_caractere

flag_casa_decimal:
    li      $t8, 1                 # decimal_point_passed = 1
    j       incrementa_indice_caractere

proximo_caractere:
    # Ignorar caracteres não numéricos
    j       incrementa_indice_caractere

incrementa_indice_caractere:
    addi    $t7, $t7, 1
    j       loop_processar_caractere

# 10 - Armazenar o número no vetor
armazena_numero:
    # Calcular o endereço para armazenar o número
    mul     $t0, $t3, 8            # Offset = índice * 8 (tamanho de double)
    add     $t1, $s1, $t0          # Endereço = vetor + offset
    s.d     $f0, 0($t1)            # Armazenar o número

    # Resetar sum_ascii para a próxima linha, se necessário
    la      $t0, double_zero
    l.d     $f6, 0($t0)            # sum_ascii = 0.0
    addi    $t3, $t3, 1            # Próxima linha
    j       loop_processar_linhas

fim_processamento_linha:
    # Fechar o arquivo
    move    $a0, $s0
    li      $v0, 16                # Syscall para fechar arquivo
    syscall

    # Exibir os números
    li      $t3, 0
    move $v0, $s1
    lw      $s6, 0($sp)
    lw      $s5, 4($sp)
    lw      $s4, 8($sp)
    lw      $s3, 12($sp)
    lw      $s2, 16($sp)
    lw      $s1, 20($sp)
    lw      $s0, 24($sp)
    lw      $ra, 28($sp)
    addi    $sp, $sp, 32
    jr      $ra 
    
 double_to_string:
    # Inicialização
    la $t1, buffer                   # Base do buffer para armazenar a string
    li $t2, 0                        # Índice do buffer
    la $t0, double_zero
    l.d $f6, 0($t0)                  # Inicializar sum_ascii = 0.0
    l.d $f2, 0($t0)                  # decimal_divider = 1.0
    li $t8, 0                        # decimal_point_written = 0

    # Converter a parte inteira
    cvt.w.d $f4, $f0                 # Converte double para inteiro
    mfc1 $t3, $f4                    # Colocar a parte inteira no registrador inteiro
    move $t9, $t3
    beqz $t3, write_zero             # Se parte inteira for 0, escrever "0"
    li $t7, 0

loop_int_part:
    # Extrair o último dígito
    li $t4, 10 	
    div $t3, $t3, $t4
    mfhi $t5                         # $t5 contém o último dígito
    addi $t7, $t7, 4
    subi $sp, $sp, 4
    sw $t5, 0($sp)
    mflo $t3                         # Atualizar número
    bnez $t3, loop_int_part
    d1:
      lw $t5, 0($sp)
      add $t5, $t5, 48
      sb $t5, 0($t1)
      addi $t1, $t1, 1
      addi $sp, $sp, 4
      subi $t7, $t7, 4
      bne $t7, $zero, d1
      
    # Escrever ponto decimal
write_decimal_point:
    li $t5, 46                       # '.'
    sb $t5, 0($t1)                   # Adicionar '.' ao buffer
    addi $t1, $t1, 1
    li $t8, 1                        # decimal_point_written = 1

    # Converter parte decimal
loop_decimal_part:
    li  $t7, 10
    mul $t9, $t9, $t7 #anterior
    mul.d $f0, $f0, $f10             # Multiplicar por 10
    cvt.w.d $f4, $f0                 # Converte para inteiro
    mfc1 $t3, $f4
    move $t7, $t3 
    sub $t3, $t3, $t9
    move $t9, $t7                   # Extrair valor inteiro        
    addi $t3, $t3, 48                # Converter para ASCII
    sb $t3, 0($t1)                   # Armazenar no buffer
    addi $t1, $t1, 1                 # Incrementar índice do buffer
    addi $t2, $t2, 1
    li $t6, 2                        # Limitar a 2 casas decimais
    ble $t6, $t2, final_double       # Se já escreveu 2 dígitos, sair

    j loop_decimal_part

write_zero:
    li $t3, 48                       # '0'
    sb $t3, 0($t1)
    addi $t1, $t1, 1
    j write_decimal_point

final_double:
    sb $zero, 0($t1)                 # Terminador nulo
    jr $ra                           # Retorna para o chamador
    
saida:
    subi $sp, $sp, 12
    sw $s6, 0($sp)
    sw $t0, 4($sp)
    sw $t2, 8($sp)
    move $t0, $a1 #base
    move $t1, $a2 #lines
    # Abrir o arquivo para escrita
    li $v0, 13  # Código do sistema para abrir arquivo (13 para escrever)
    li $a1, 1            
    syscall
    
    move $s6, $v0
    
    l.d $f14, double_um
    
    j write_loop

write_loop:
    # Carrega um valor do array
    l.d $f0, 0($t0)
    
    subi $sp, $sp, 20
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $s6, 8($sp)
    sw $t2, 12($sp)
    sw $ra, 16($sp)
    
    jal double_to_string
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $s6, 8($sp)
    lw $t2, 12($sp)
    lw $ra, 16($sp)
    addi $sp, $sp, 20
    
    # Escreve a string no arquivo
    li $v0, 15  # Código do sistema para escrever string
    move $a0, $s6 
    la $a1, buffer
    li $a2, 256
    syscall
        
    # Atualiza o endereço do array
    addi $t0, $t0, 8

    # Decrementa o contador
    sub $t1, $t1, 1
    bnez $t1, call_loop  # Se o contador não for zero, continue o loop

    # Fechar o arquivo
    li $v0, 16  # Código do sistema para fechar o arquivo
    move $a0, $s6
    syscall
    
    lw $s6, 0($sp)
    lw $t0, 4($sp)
    lw $t2, 8($sp)
    addi $sp, $sp, 12

    jr $ra
    
call_loop:
    li $v0, 15  # Código do sistema para escrever string
    move $a0, $s6 
    la $a1, newline
    li $a2, 1
    syscall
    
    j write_loop

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
    
    lw $t1, 4($sp) #w
    lw $t3, 0($sp) #tam_y
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
    	slt $t5, $t0, $t3        # i < tam_y
    	bne $t5, $zero, LOOP
    	addi $sp, $sp, 8 #restaura a pilha de execução
    	move $v0, $a0 # x_train_new
    	move $v1, $a1# y
    	jr $ra
