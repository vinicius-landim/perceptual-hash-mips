.data
filename:  .asciiz "C:/Users/lvini/Desktop/Programacao/AOC/saida.txt"  # Arquivo a ser criado contendo o caminho até as imagens
buffer:    .space 256 # Buffer para armazenar a entrada do usuário
msg_input: .asciiz "Digite o caminho para dois arquivos de imagem separados por espaço: "

.text
.globl main

main:
	# Exibe mensagem de input
	li $v0, 4
	la $a0, msg_input
	syscall

	# Le a string digitada pelo usuario
	li $v0, 8
	la $a0, buffer  # Endereço do buffer
	li $a1, 256     # Tamanho máximo
	syscall

	#Abrir o arquivo
	li $v0, 13		#codigo para abrir o arquivo
	la $a0, filename
	li $a1, 1	 #permissão para criar o arquivo caso ele não exista, e se existir, sobrescreve
	syscall 
    
	move $s0, $v0
    
	#escrever no arquivo
	li $v0, 15		#codigo do modo de escrita 
	move $a0, $s0	#chama file descriptor (identificador do arquivo a ser escrito)
 	la $a1, buffer	#buffer contendo o conteudo a ser escrito
	li $a2, 256		#tamanho maximo do conteudo
	syscall
    	
	#fechar o arquivo
	li $v0, 16		#codigo para fechar o arquivo
	move $a0, $s0	#identifica qual arquivo deve ser fechado através do file descriptor
	syscall

	# Encerrar programa
	li $v0, 10
	syscall
