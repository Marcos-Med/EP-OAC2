.data
    nome_arquivo:       .asciiz "C:\\Users\\Usuario\\Documents\\USP\\4_SEMESTRE\\OAC2\\EP1\\x_train.txt"
    nome_outro:         .asciiz "C:\\Users\\Usuario\\Documents\\USP\\4_SEMESTRE\\OAC2\\EP1\\x_test.txt"
    buffer:             .space 256        # Buffer para leitura de linhas
    newline:            .asciiz "\n"
    contador_linha:     .word 0

    # Definição dos valores de ponto flutuante (agora como double)
    double_zero:         .double 0.0
    double_um:           .double 1.0
    double_dez:          .double 10.0
    
    msg_x:  .asciiz "Matrix x:\n"	
    space:  .asciiz " "

.text
.globl main
# Função principal
main:
    # Chamada da função leitura_arquivo com nome_arquivo
    la      $a0, nome_arquivo      # Ponteiro para o nome do arquivo
    jal     leitura_arquivo         # Chama leitura_arquivo
    move    $s1, $v0
    
    # Chamada da função leitura_arquivo com nome_outro
    la      $a0, nome_outro        # Ponteiro para o outro arquivo
    jal     leitura_arquivo         # Chama leitura_arquivo novamente
    move    $s2, $v0
    
    la $s0, contador_linha
    lw $s0, 0($s0)
    
    li $v0, 4
    la $a0, msg_x
    syscall
    move $a0, $s0
    li $a1, 1
    move $a2, $s1
    jal print_matrix
    
    li $v0, 4
    la $a0, msg_x
    syscall
    move $a0, $s0
    li $a1, 1
    move $a2, $s2
    jal print_matrix
    

    j       fim                     # Salta para o fim do programa

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

fim:
    li      $v0, 10                # Syscall para sair
    syscall
