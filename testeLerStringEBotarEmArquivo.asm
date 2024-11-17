.data
    # Caminho do arquivo de saída
    pathYTest: .asciiz "C:\\Users\\Usuario\\Documents\\USP\\4_SEMESTRE\\OAC2\\EP1\\saida.txt"
    
    # Array de doubles
    vetor: .double 3.14, 2.718, 1.414, 1.732, 0.577

    # Buffer para conversão (tamanho suficiente para armazenar a string)
    buffer: .space 100        # Tamanho do buffer para a string convertida
    newline: .asciiz "\n"     # Nova linha

.text
.globl main
main:
    ### ABRIR ARQUIVO PARA ESCRITA ###
    la $a0, pathYTest        # Caminho do arquivo de saída
    li $a1, 1                # Modo escrita
    li $v0, 13               # Syscall para abrir arquivo
    syscall
    bltz $v0, error_exit     # Se erro, sair
    move $t0, $v0            # Guardar descritor do arquivo

    ### ITERAR PELO ARRAY E ESCREVER CADA DOUBLE ###
    la $t1, vetor            # Ponteiro para o início do array
    li $t2, 5                # Número de elementos no array (ajuste conforme necessário)
     l.d $f12, 0($t1)         # Carregar double no registrador $f12
    mov.d $f0, $f12
    li $v0, 2
    syscall

loop_write:
    beqz $t2, end_write      # Se contador for 0, terminar loop

    # Carregar próximo double
    l.d $f12, 0($t1)         # Carregar double no registrador $f12
    

    # Converter double para string manualmente
    # (Aqui, você precisará implementar a conversão manual para string)

    # Para simplicidade, neste exemplo, vamos escrever um valor fixo (como string)
    # Você pode substituir isso por um processo real de conversão de double para string

    li $v0, 4                # Syscall para imprimir string (apenas como exemplo)
    la $a0, buffer           # Endereço do buffer (onde a string será armazenada)
    syscall

    # Escrever nova linha no arquivo
    la $a1, newline          # Endereço do caractere de nova linha
    li $a2, 1                # Tamanho do caractere
    li $v0, 15               # Syscall para escrever no arquivo
    syscall

    # Atualizar ponteiro para o próximo double
    addiu $t1, $t1, 8        # Avançar 8 bytes (tamanho de um double)
    subi $t2, $t2, 1         # Decrementar contador
    j loop_write             # Repetir

end_write:
    ### FECHAR ARQUIVO ###
    li $v0, 16               # Syscall para fechar arquivo
    move $a0, $t0            # Descritor do arquivo
    syscall

    ### ENCERRAR PROGRAMA ###
    li $v0, 10               # Syscall para terminar o programa
    syscall

error_exit:
    li $v0, 10               # Encerrar programa em caso de erro
    syscall
