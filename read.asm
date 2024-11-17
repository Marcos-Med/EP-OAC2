.data
nome_arquivo:       .asciiz "C:\\Users\\paulo\\Downloads\\oac2.txt"
buffer:             .space 256        # Buffer para leitura de linhas
newline:            .asciiz "\n"
contador_linha:     .word 0 # tam

# Definição dos valores de ponto flutuante (agora como double)
float_zero:         .double 0.0
float_um:           .double 1.0
float_dez:          .double 10.0

.text
.globl main
main:
    # 1 - Abrir o arquivo "teste.txt" no caminho especificado
    la      $a0, nome_arquivo      # Ponteiro para o nome do arquivo
    li      $a1, 0                 # Modo de leitura
    li      $v0, 13                # Syscall para abrir arquivo
    syscall
    move    $s0, $v0               # $s0 = descritor de arquivo

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
    j       apos_contar_linhas

incremento_contador_linhas_fim:
    # Se o arquivo não terminar com '\n', incrementa o contador
    addi    $t0, $t0, 1
    sw      $t0, contador_linha

apos_contar_linhas:

    # 5 - Criar um vetor com o tamanho da quantidade de linhas
    # Calcular o tamanho necessário para o vetor
    lw      $t0, contador_linha
    li      $t1, 8                 # Tamanho de double em bytes
    mul     $t2, $t0, $t1          # Tamanho total = num_linhas * 8

    # Alocar memória para o vetor
    move    $a0, $t2               # Tamanho para alocar
    li      $v0, 9                 # Syscall para sbrk (alocação de memória)
    syscall
    move    $s1, $v0               # Ponteiro para o vetor numbers

    # Fechar o arquivo para reposicionar o ponteiro
    move    $a0, $s0
    li      $v0, 16                # Syscall para fechar arquivo
    syscall

    # Reabrir o arquivo
    la      $a0, nome_arquivo
    li      $a1, 0
    li      $v0, 13
    syscall
    move    $s0, $v0

    # 3 - Loop de 0 até a quantidade de linhas
    li      $t3, 0                 # Índice da linha atual
loop_processar_linhas:
    lw      $t0, contador_linha
    bge     $t3, $t0, fim_processamento_linha

    # 4 - Ler cada linha até encontrar '\n'
    # Inicializar índice do buffer
    li      $t4, 0                 # Índice do buffer
loop_ler_linhas:
    move    $a0, $s0
    la      $a1, buffer
    add     $a1, $a1, $t4          # $a1 = buffer + $t4
    li      $a2, 1
    li      $v0, 14
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

    # 5 - Inicializar um double com 0.0
    la      $t0, float_zero
    l.d     $f0, 0($t0)            # num = 0.0
    li      $t7, 0                 # Índice do buffer
    li      $t8, 0                 # decimal_point_passed = 0
    la      $t0, float_um
    l.d     $f2, 0($t0)            # decimal_divider = 1.0

    # Inicializar sum_ascii = 0.0
    la      $t0, float_zero
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

    # 6 - Verificar se o caractere é dígito ou '.'
    li      $t6, 46                # '.'
    beq     $t9, $t6, flag_casa_decimal
    li      $t0, 48                # '0'
    li      $t1, 57                # '9'
    blt     $t9, $t0, proximo_caractere
    bgt     $t9, $t1, proximo_caractere

    # 7 e 8 - Construir o número
    sub     $t2, $t9, 48           # Converter caractere para dígito
    mtc1    $t2, $f4               # Move digit to $f4
    cvt.d.w $f4, $f4               # Convert to double

    beqz    $t8, antes_casa_decimal

depois_casa_decimal:
    # decimal_divider *= 10
    la      $t0, float_dez
    l.d     $f10, 0($t0)           # Load 10.0 into $f10
    mul.d   $f2, $f2, $f10         # decimal_divider *= 10
    # num += digit / decimal_divider
    div.d   $f8, $f4, $f2          # $f8 = digit / decimal_divider
    add.d   $f0, $f0, $f8          # num += $f8
    j       incrementa_indice_caractere

antes_casa_decimal:
    # num = num * 10
    la      $t0, float_dez
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
    la      $t0, float_zero
    l.d     $f6, 0($t0)            # sum_ascii = 0.0
    addi    $t3, $t3, 1            # Próxima linha
    j       loop_processar_linhas

fim_processamento_linha:
    # Fechar o arquivo
    move    $a0, $s0
    li      $v0, 16
    syscall

    # Exibir os números
    li      $t3, 0
loop_printar_numeros:
    lw      $t0, contador_linha
    bge     $t3, $t0, fim
    mul     $t1, $t3, 8            # Índice * tamanho de double
    add     $t2, $s1, $t1
    l.d     $f12, 0($t2)           # Carregar o número
    li      $v0, 3                 # Syscall para imprimir double
    syscall

    # Imprimir nova linha
    li      $v0, 11
    li      $a0, 10S
    syscall
    addi    $t3, $t3, 1
    j       loop_printar_numeros

fim:
    li      $v0, 10                # Syscall para sair
    syscall