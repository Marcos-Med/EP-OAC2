.data
x_teste: .double 1.5 2.1 3.2 4.0 5.2 6.1 2.7 7.1 3.2 
x_train: .double 1.1 2.2 3.3 4.4 5.5 6.6 7.7 8.8 9.9 
y_train: .double 4.4 5.5 6.6
k: .word 2
w: .word 3
h: .word 1
tam: .word 9
msg_y:  .asciiz "Vector y:\n"
msg_x:  .asciiz "Matrix x:\n"
newline: .asciiz "\n"
space:  .asciiz " "
const: .double 999999999.9999

.text
.globl main
main:
    la $t1, k
    la $t2, h
    la $t3, w
    la $t4, tam
    lw $s0, 0($t1)  #k          
    lw $s1, 0($t2)  #h           
    lw $s2, 0($t3)  #w           
    lw $t0, 0($t4)  #tam
    
    # Calcula o número de linhas do array y
    addi $t2, $zero, 3
    
    la $s3, x_teste
    la $s4, x_train
    la $s5, y_train
	
    # Aloca espaço para x_train
    sll $t3, $t2, 3
    li $v0, 9               
    add $a0, $zero, $t3
    syscall
    move $s6, $v0           # $s6 = base de y_pred
    
    #Vetor auxiliar de distância
    sll $t3, $t2, 3 #linhas
    mul $t3, $t3, $t2 #matrix linhaxlinha
    li $v0, 9               
    add $a0, $zero, $t3
    syscall
    move $s7, $v0           # $s7 = base de dist
    
    dist:
    	li $t6, 0 #k -> teste
    	L1:
	  li $t1, 0 #i -> train
	  L2:
	     li $t4, 0
	     mtc1 $t4, $f4
	     cvt.d.w $f4, $f4
	     li $t3, 0 #j
	  	L3:
	     	   mul $t4, $t1, $s2 #i*w
	           add $t4, $t4, $t3 #[i][j]
	           sll $t4, $t4, 3
	           add $t5, $t4, $s4 #x_train[i][j]
	           l.d $f2, 0($t5) #x_train
	           mul $t4, $t6, $s2 #k*w
	           add $t4, $t4, $t3#[k][j]
	           sll $t4, $t4, 3
	           add $t5, $t4, $s3 #x_teste[k][j]
	           l.d $f0, 0($t5)
	           sub.d $f0, $f0, $f2 #(x1-x2)
	           mul.d $f0, $f0, $f0 #(x1-x2)^2
	           add.d $f4, $f4, $f0 #distância
	           addi $t3, $t3, 1 #j++
	           slt $t4, $t3, $s2 # j < w
	           bne $t4, $zero, L3
	       mul $t4, $t6, $t2
	       add $t4, $t4, $t1
	       sll $t4, $t4, 3
	       add $t4, $t4, $s7 #dist[k][i]
	       s.d $f4, 0($t4)#dist
	       addi $t1, $t1, 1#i++
	       slt $t4, $t1, $t2 # i < linhas
	       bne $t4, $zero, L2
	    addi $t6, $t6, 1
	    slt $t4, $t6, $t2 # k < linhas
	    bne $t4, $zero, L1
	#matriz de distância pronta ($s7)
	
	sll $t4, $s0, 3
	li $v0, 9
	add $a0, $zero, $t4
	syscall
	move $t8, $v0 #vetor auxiliar de dist (k)
	li $t1, 0
	la $t3, const
	l.d $f0, 0($t3)
	loop:
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
	
     k_vizinhos:
     	   li $t1, 0 #i -> teste
     	   K1:
     	   	li $t3, 0 #j -> train 
     	   	K2:
     	   	    mul $t4, $t1, $t2
     	   	    add $t4, $t4, $t3
     	   	    sll $t4, $t4, 3
     	   	    add $t4, $t4, $s7
     	   	    l.d $f0, 0($t4)
     	   	    sll $t4, $t3, 3
     	   	    add $t4, $t4, $s5
     	   	    l.d $f2, 0($t4)
     	   	    j less_than
     	   	    return:
     	   	    addi $t3, $t3, 1
     	   	    slt $t4, $t3, $t2
     	   	    bne $t4, $zero, K2
     	   	 li $t4, 0
     	   	 mtc1 $t4, $f2
     	   	 cvt.d.w $f2, $f2
     	   	 sum:  	  
     	   	 	sll $t5, $t4, 3
     	   	 	add $t5, $t5, $t9
     	   	 	l.d $f0, 0($t5)
     	   	 	add.d $f2, $f2, $f0
     	   	 	addi $t4, $t4, 1
     	   	 	slt $t5, $t4, $s0
     	   	 	bne $t5, $zero, sum
     	   	 mtc1 $s0, $f0
     	   	 cvt.d.w $f0, $f0
     	   	 div.d $f2, $f2, $f0
     	   	 sll $t4, $t1, 3
     	   	 add $t4, $t4, $s6
     	   	 s.d $f2, 0($t4)
	la $t4, const
	l.d $f0, 0($t4)
	li $t4, 0
	loop_2:
		sll $t6, $t4, 3
		add $t6, $t6, $t8
		s.d $f0, 0 ($t6)
		addi $t4, $t4, 1
		slt $t6, $t4, $s0
		bne $t6, $zero, loop_2
     	 addi $t1, $t1, 1
     	 slt $t4, $t1, $t2
     	 bne $t4, $zero, K1
 # Imprime vetor y_pred
    li $v0, 4
    la $a0, msg_y
    syscall
    move $a0, $t2 # linhas_y
    addi $a1, $zero, 1
    move $a2, $s6 # base y_pred
    jal print_matrix
    li $v0, 4
    la $a0, msg_x
    syscall
    li $a0, 3
    li $a1, 3
    move $a2, $s7
    jal print_matrix
    j done
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
 	 	sll $t7, $s0, 3
 	 	add $t7, $t7, $t8
 	 	l.d $f6, 0($t7)
 	 	c.lt.d $f0, $f6
 	 	move $t5, $s0
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
     	   		
     	   	    		
     	   	    
	
     
	     

    
