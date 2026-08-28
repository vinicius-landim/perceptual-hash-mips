.data
filename1: .asciiz "C:/Users/lvini/Desktop/Programacao/dctArrayImg1.bin"
filename2: .asciiz "C:/Users/lvini/Desktop/Programacao/dctArrayImg2.bin"
    .align 2
dct_array1: .space 256 			
dct_array_sorted1: .space 256 
dct_array2: .space 256 		
dct_array_sorted2: .space 256 
error_msg: .asciiz "Erro ao abrir ou ler o arquivo.\n"

float_two: 	.float 2.0	
median:         .float 0.0
length:		.word 64
float_length:	.float 64.0
hash1_msg:	.asciiz "Hash (em binario) da Imagem 1: "
hash2_msg:	.asciiz "Hash (em binario) da Imagem 2: "
result_msg: 	.asciiz "Distancia de Hamming: "
result_msg_norm: .asciiz "Distancia de Hamming Normalizada: "
newline:    	.asciiz "\n"


.text

.globl main
	
main: 	
	#Lendo os arquivos e armazenando seu coteudo nos buffers dct_array(1 e 2) e dct_array_sorted(1 e 2)
	jal read_file1
	jal read_fileSort
	jal read_file2
	jal read_fileSort2
	# inicializando valores
	lw $s0, length 
	la $s1, dct_array1
	la $s2, dct_array_sorted1
	la $s3, dct_array2
	la $s4, dct_array_sorted2

	#I) ORDENANDO OS VALORES PARA OBTER A MEDIANA
	move $a1, $s2
	jal sort_array
	
	#II) OBTENDO A MEDIANA
	move $a1, $s2
	jal calc_median
	
	#III) FORMAÇÃO DO HASH COMPARANDO O VALOR MEDIANO COM CADA ELEMENTO DA MATRIZ
	move $a1, $s1
	jal compare_element_with_median
	move $s1, $a2 #$S1 -> Dígitos LSB da Figura 1
	move $s2, $a3 #$S2 -> Dígitos MSB da Figura 1


	#I) ORDENANDO OS VALORES PARA OBTER A MEDIANA
	move $a1, $s4
	jal sort_array
	
	#II) OBTENDO A MEDIANA
	move $a1, $s4
	jal calc_median
	
	#III) FORMAÇÃO DO HASH COMPARANDO O VALOR MEDIANO COM CADA ELEMENTO DA MATRIZ
	move $a1, $s3
	jal compare_element_with_median
	move $s3, $a2 #$S3 -> Dígitos LSB da Figura 2
	move $s4, $a3 #$S4 -> Dígitos MSB da Figura 2
	
	#IV) CALCULANDO HAMMING DISTANCE
	move $a0, $s1
	move $a1, $s3
	move $a2, $s2
	move $a3, $s4
	jal hamming_distance #$s5 contém o valor de Hamming Distance
	jal normalize_hamming_distance #$f4 contém o valor de Normalized Hamming Distance
	
	#V) IMPRIMINDO O HASH EM BINÁRIO
	
	# Imprime 'Hash (em binario) da Imagem 1:  '
    	li $v0, 4
    	la $a0, hash1_msg
    	syscall
    	
	move $a1, $s2 # MSB Figura 1
	jal print_binary 
	move $a1, $s1
	jal print_binary # LSB Figura 1

	jal print_new_line
    	
    	# Imprime 'Hash (em binario) da Imagem 2:  '
    	li $v0, 4
    	la $a0, hash2_msg
    	syscall
    	
    	move $a1, $s4 # MSB Figura 2
	jal print_binary 
	move $a1, $s3
	jal print_binary # LSB Figura 2

	jal print_new_line
	jal print_new_line
    	
    	#VI) IMPRIMINDO HAMMING DISTANCE E NORMALIZED HAMMING DISTANCE
    	
    	# Imprime 'Distancia de Hamming: '
    	li $v0, 4
    	la $a0, result_msg
    	syscall
    	
    	move $a0, $s5
	li $v0, 1
	syscall
	
	jal print_new_line
	
	# Imprime 'Distancia de Hamming Normalizada: '
    	li $v0, 4
    	la $a0, result_msg_norm
    	syscall
	
	li $v0, 2
    	mov.s $f12, $f4
    	syscall
    	
    	jal print_new_line
    	
    	li $v0, 10
    	syscall


#FUNÇÃO SORT_ARRAY: Ordenação de Array
# Parâmetros: 
#	- $a1 = $dct_sorted_array
# Retorno:
#	- Array ordenada do endereço de $a1
sort_array:
	li $t1, 0 # i = 0
	addi $t2, $s0, -1 # i = n-1   
bubble_sort:
	#(i=0; i<n-1)
	bge $t1, $t2, bubble_sort_exit
	li $t3, 0 #j=0 para o inner loop
bubble_sort_inner_loop:
	sub $t4, $s0, $t1 # $t4 = n - i
   	addi $t4, $t4, -1	# $t4 = n - i - 1
	bge $t3, $t4, i_increment # se j>= n-1-i, i++ e retorna ao loop externo
	
	#obtendo dct_array[j] e dct_array[j+1]
	sll $t5, $t3, 2 #indice j corrigido para ocupação de 4bytes do tipo float (deslocamento à esquerda em dois bits <=> multiplicar por 2^2)
	add $t5, $t5, $a1 # j = j + dct_array
	l.s $f0, 0($t5) # $f0 = dct_array[j]
	
	addi $t6, $t5, 4
	l.s $f1, 0($t6) #$f1 = dct_array[j+1]
	
	# if (dct_array[j] > dct_array[j+1]) swap;
	c.le.s $f1, $f0
	bc1t swap
	
	j j_increment # como j<n-1-i e arr[j] < arr[j+1], j++ e segue o loop interno
	
i_increment:
	addi $t1, $t1, 1 #i++
	j bubble_sort 
	
j_increment:
	addi $t3, $t3, 1 #j++
	j bubble_sort_inner_loop
	
swap:
	s.s $f0, 0($t6) # dct_array[j+1] = dct_array[j]
	s.s $f1, 0($t5) # dct_array[j] = dct_array[j+1]	
	j j_increment 
	
bubble_sort_exit:
    	jr $ra
    	

# FUNÇÃO CALC_MEDIAN: Obtém mediana e salva em "median"
#Parâmetros:
#	$a1 = $dct_array_sorted
#Retorno:
#	- Valor da mediana salvo em "median"
calc_median:
	li $t0, 0 # inicializando index: $t0 = 0
    	li $t4, 2
    	div $t0, $s0, $t4 # t0=length/2
calc_median_even:
    	sll $t6, $t0, 2 # correção do index
    	add $t6, $t6, $a1  # index = index + dct_sorted_array
    	l.s $f1, 0($t6) # f1 = dct_array_sorted[index]

    	addi $t6, $t6, -4 # $t6 = index - 1 (elemento anterior)
    	l.s $f2, 0($t6) # f2 = dct_array_sorted[index-1]

    	add.s $f0, $f1, $f2 # f0 = dct_array_sorted[index] + dct_array_sorted[index - 1]
    	l.s $f1, float_two  # $f1 = 2.0 para divisao do tipo float
    	div.s $f0, $f0, $f1
    	
    	s.s $f0, median # salva a mediana (útil para verificação)
    	jr $ra


#FUNÇÃO COMPARE_ELEMENT_WITH_MEDIAN: Obtém o número binário correspondente, o dividindo em 2 registradores
#Parâmetros:
	# $a1 -> &dct_array
#Retornos:
	# $a2 -> Registrador com MSB
	# $a1 -> Registrador com LSB
compare_element_with_median:
	move $t0, $s0 # inicializando índice: $t0 = k = length, que será o indice de percorrimento do LSB para o MSB
	addi $t0, $t0, -1 # corrigindo indice para acesso na array
	addi $t9, $t9, 0 #indice para deslocamento do bit
	li $a2, 0 # inicializando número binário do output do registrador da parte menos significativa
	li $a3, 0 #inicializando o número binário do output do registrador para parte mais significativa
	l.s $f0, median # $f0 = median

compare_element_with_median_loop:
	blt $t0, $zero , compare_exit
	
	sll $t2, $t0, 2 #correção índice 4 bytes
	add $t3, $a1, $t2 # $t3 = k + dct_array
	l.s $f1, 0($t3) #$f1 = dct_array[k]
	
	c.lt.s $f1, $f0 #se f1 < f0, bit é definido como 0
	bc1t set_zero
	
	#caso contrário, é definido como 1	
	blt $t0, 32, set_bit_reg2 #caso o indice seja menor que 32, começa a passar os bits para o outro registrador

	li $t4, 1 #inicializando numero binario (set_one)
	sllv $t4, $t4, $t9 #deslocar 1 para sua posicao do numero binário
	or $a2, $a2, $t4 #atualiza numero binario do output com a operação OR
	j index_update
	
set_bit_reg2:
	li $t4, 1
	sllv $t4, $t4, $t9
	or $a3, $a3, $t4
	j index_update
	
set_zero:
	nop #nada a ser feito, pois o número ficará inalterado (e o deslocamento da posição já inclui o 0), seguindo para index_update

index_update:
	addi $t0, $t0, -1 #acessar elemento anterior da array
	addi $t9, $t9, 1 #+1 no deslocamento do bit
	j compare_element_with_median_loop
	
compare_exit:
	jr $ra
    	
# FUNÇÃO HAMMING DISTANCE: Obtém o total de bits não correspondentes
# Parâmetros: 
#	- $a0: Endereço do registrador que contém LSB da Figura 1
#	- $a1: Endereço do registrador que contém LSB da Figura 2
#	- $a2: Endereço do registrador que contém MSB da Figura 1
#	- $a3: Endereço do registrador que contém MSB da Figura 2
# Retornos:
#	- $s5: Total obtido
hamming_distance:
	li $s5, 0 # Inicializa o contador de bits diferentes

	# XOR entre os dois números para identificar os bits diferentes
	xor $t1, $a0, $a1 # Compara os primeiros 32 bits
	xor $t2, $a2, $a3 # Compara os últimos 32 bits

	# Conta os bits 1 em $t1
count_bits_1:
	beqz $t1, count_bits_2 # Se $t1 for 0, pula para o próximo bloco
	andi $t3, $t1, 1 # Verifica o bit menos significativo de $t1
	add $s5, $s5, $t3 # Soma 1 ao contador se o bit for 1
	srl $t1, $t1, 1 # Desloca $t1 para a direita
	j count_bits_1 # Continua até $t1 ser 0

	# Conta os bits 1 em $t2
count_bits_2:
	beqz $t2, count_exit # Se $t2 for 0, finaliza
	andi $t3, $t2, 1 # Verifica o bit menos significativo de $t2
	add $s5, $s5, $t3 # Soma 1 ao contador se o bit for 1
	srl $t2, $t2, 1 # Desloca $t2 para a direita
	j count_bits_2 # Continua até $t2 ser 0

count_exit:
	jr $ra

# FUNÇÃO NORMALIZE HAMMING DISTANCE: Normaliza o total, obtendo um coeficiente. (total/length)
# Parâmetros: 
#	- Nenhum. Já opera com $s5
# Retornos:
#	- $f2: Coeficiente obtido
normalize_hamming_distance:
	l.s $f0, float_length      
	# Converte o inteiro da distancia de Hamming em ponto flutuante
	mtc1 $s5, $f2  # Move o valor de $t0 para o registrador de ponto flutuante $f2
	cvt.s.w $f2, $f2  # Converte o valor inteiro para ponto flutuante (no registrador $f2)

	# Realiza a divisao normalizada (distancia / 64.0)
	div.s $f4, $f2, $f0 # Divide $f2 (distancia) por $f0 (64.0)	
   	jr $ra
   	
# FUNÇÃO PRINT_NEW_LINE: Imprime nova linha
print_new_line:
	li $v0, 4 
    	la $a0, newline 
    	syscall 
    	jr $ra	
    	
# FUNÇÃO PRINT_BINARY: Imprime o número binário correspondente ao registrador
# Parâmetros:
#	- $a1: $Registrador que será impresso
# Retornos:
	# Impressão 
print_binary:
    	li $t2, 31 # carrega o valor 31 em $t2 (o primeiro deslocamento posicionará o primeiro bit de $a1 na posição de LSB)
print_binary_loop:
    	blt $t2, $zero, print_binary_exit  # Se $t2 for menor que zero, sai do loop (acabaram os bits)

    	srlv $t3, $a1, $t2 #a partir do LSB, selecionará $t2 bits em direção ao MSB. Assim, teremos os bits 32-$t2 bits mais significativos, em que com o deslocamento, o bit da posicao 32-$t2 estará isolado
    			   #exemplo 10010: 10010 >> 4 -> 00001 + 00001 = '1'; 10010 >> 3 -> 00010 ^ 00001 = '0'; 10010 >> 2 -> 00100 ^ 00001 = '0'; 10010 >> 1 -> 01001 ^ 00001 = '1'; 10010 >> 0 -> 10010 ^ 1 = '0'
    			   #Note que a impressão seria: 10010
    	andi $t3, $t3, 1 # com o bit desejado isolado, fazendo a operação de AND com o bit 1, $t3 receberá aquele bit em específico (ex: 0010 + 0001 = 0000 ou 0011 + 0001 = 0001)

    	addi $t3, $t3, 48 # converte o bit em caractere ASCII (0+48 = '0' ou 1+48 = '1')
    	li $v0, 11 #imprime caractere (ASCII). Note que o algoritmo imprime do mais significativo ao menos significativo
    	move $a0, $t3
    	syscall 

    	addi $t2, $t2, -1 # decrementa $t2 para o próximo bit
    	j print_binary_loop

print_binary_exit:
    	jr $ra
    	
# As funções file_readSort1 e 2 e read_file2 operam de maneira análoga a esta, sendo substituido apenas o buffer destino ou o arquivo a ser lido
read_file1:
    # Abre o arquivo solicitado e inicia o modo de leitura
    li   $v0, 13          #código para abrir o arquivo 
    la   $a0, filename1  
    li   $a1, 0          #Flags para iniciar o modo de leitura
    li   $a2, 0           
    syscall
    bltz $v0, error       # Caso a operação falhe, exibe mensagem de erro e encerra o programa 
    move $s0, $v0         # Tira o file descriptor de v0

    #Le o arquivo e guarda seu conteudo em dct_array1
    li   $v0, 14          # Código para leitura 
    move $a0, $s0         # Chama o file descriptor (armazenado em $s0)
    la   $a1, dct_array1  # Endereço do buffer de destino
    li   $a2, 256         # Número de bytes a ler
    syscall
    bltz $v0, error       # Caso ocorra um erro na leitura, exibir mensagem de erro e encerrar programa

    # Fechar arquivo
    li   $v0, 16          # Código para fechar arquivo
    move $a0, $s0         # File descriptor
    syscall
    jr   $ra             

read_fileSort:
    li   $v0, 13          
    la   $a0, filename1   
    li   $a1, 0           
    li   $a2, 0           
    syscall
    bltz $v0, error      
    move $s0, $v0         

    li   $v0, 14          
    move $a0, $s0        
    la   $a1, dct_array_sorted1  
    li   $a2, 256        
    syscall
    bltz $v0, error      

    li   $v0, 16          
    move $a0, $s0         
    syscall
    jr   $ra              
    
read_file2:
    li   $v0, 13         
    la   $a0, filename2   
    li   $a1, 0          
    li   $a2, 0          
    syscall
    bltz $v0, error     
    move $s0, $v0        

    li   $v0, 14          
    move $a0, $s0        
    la   $a1, dct_array2  
    li   $a2, 256         
    syscall
    bltz $v0, error      

    li   $v0, 16          
    move $a0, $s0         
    syscall
    jr   $ra             
    
read_fileSort2:
    li   $v0, 13          
    la   $a0, filename1   
    li   $a1, 0          
    li   $a2, 0         
    syscall
    bltz $v0, error      
    move $s0, $v0        

    li   $v0, 14          
    move $a0, $s0         
    la   $a1, dct_array_sorted2  
    li   $a2, 256         
    syscall
    bltz $v0, error       

    li   $v0, 16          
    move $a0, $s0         
    syscall
    jr   $ra              

#Imprime mensagem de erro e encerra o programa
error:
    li   $v0, 4           
    la   $a0, error_msg
    syscall

    li   $v0, 10        
    syscall
    	
