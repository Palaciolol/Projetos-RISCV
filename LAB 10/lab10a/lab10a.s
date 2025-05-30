.globl linked_list_search           
.globl atoi
.globl itoa
.globl gets
.globl puts
.globl exit

.bss
    input:     .space 400  #buffer

.section .text
.align 2

read: 
    li a0, 0                #file descriptor = 0 (stdin)
    li a2, 1                #vou ler 1 byte
    li a7, 63               #syscall read (63)
    ecall
    ret                     #retorno da função


//function to write data on the standart output
write: 
    li a0, 1                #file descriptor = 1 (stdout)
    li a2, 1                #size
    li a7, 64               #syscall write (64)
    ecall
    ret                     #retorno da função 

#a0 --> endereço do head node
#a1 --> valor a ser procurado
linked_list_search:
    li t0, 0            #indice da lista (inicia em 0)
    loop2:
    beqz a0, not_found  #se NEXT == 0, fim da lista (não encontrado)
    lw t1, 0(a0)        #carrega VAL1
    lw t2, 4(a0)        #carrega VAL2
    add t3, t1, t2      #t3 = VAL1 + VAL2
    beq t3, a1, found   #se VAL1 + VAL2 == a1, vai para found
    lw a0, 8(a0)        #carrega o próximo nó
    addi t0, t0, 1      #incrementa o índice
    j loop2             #recomeça o loop
    found:
    mv a0, t0           #coloca o índice em a0
    ret
    not_found:
    li a0, -1
    ret


#a0 --> esse registrador guarda o valor do número a ser convertido
#a1 --> endereço da string que eu vou por os valores
#a2 --> base pra qual eu vou converter
itoa:
    addi sp, sp, -16
    sw a1, 0(sp)    
    bnez a0, cont4
    li t0,'0'
    sb t0, 0(a1)
    sb zero, 1(a1)
    lw a0, 0(sp)         #pega o valor de ra da pilha
    addi sp, sp, 16      #incrementa sp
    ret
    cont4:
    li t0, 0        #variável de fim de laço
    li t2, 10       #eu suponho que a base é 10
    mv t3, a0       #coloco o número a ser convertido em t3
    bne a2, t2, base_16
    blt a0, t0, menor_que_zero
    j loop_aux
    menor_que_zero:
    li t5, '-'
    sb t5, 0(a1)
    neg t3, t3
    neg a0, a0
    addi a1, a1, 1 
    j loop_aux
    base_16:
    li t2, 16
    loop_aux:
    beq t3, zero, cont
    addi a1, a1, 1
    div t3, t3, t2
    j loop_aux
    cont:
    sb zero, 0(a1)
    addi a1, a1, -1
    laco2:
        li t1, 10
        beq a0, zero, fim      #confere se o número já é igual a zero(fim do laço)
        remu t3, a0, t2        #pega o resto da divisão pela base
        bge t3, t1, soma_55    #confere se o número é maior ou igual a 10
        addi t3, t3 ,'0'       #t3 recebe ele mesmo mais o caractere 0 pra transformar em string
        j cont2
        soma_55:
        addi t3, t3, 'A'-10
        cont2:
        sb t3, 0(a1)           #coloco esse byte na posição correta da string
        addi a1, a1, -1        #subtrai a1
        divu a0, a0, t2        #a0 recebe ele mesmo dividido pela base
        j laco2                #pula pro laço de novo
    fim:
        lw a0, 0(sp)         #pega o valor de ra da pilha
        addi sp, sp, 16      #incrementa sp
        ret

#a0 --> endereço da string
atoi:
    li t2, 10
    li t4, '-'
    li a1, 0
    lb t5, 0(a0)            #t5 = valor da memória da string no endereço a0
    bne t5, t4, laco  #se tiver um menos, eu seto uma flag
    li t6, -1
    addi a0, a0, 1
    laco:
        lb t5, 0(a0)
        beq t5, zero, acabou    #se o byte caregado for um \0, acabou
        mul a1, a1, t2          #multiplica a1 por 10 e salva em a1
        addi t5, t5, -'0'       #converte t2 para valor numérico
        add a1, a1, t5          #a1 = a1 + t5
        addi a0, a0, 1          #a0 = a0 + 1
        j laco
        
    acabou:
        li t0, -1
        beq t6, t0, negativo
        j cont3
        negativo:
        neg a1, a1
        mv a0, a1
        ret
        cont3:
        mv a0, a1
        ret    

#a0 tem o endereço da string que é pra printar
puts:
    addi sp, sp, -16
    sw ra, 0(sp)
    mv a1, a0   #coloca o endereço que vou printar em a1
    li t0, 0    #caractere '\0' , final de string
    loop3:
        lb t1, 0(a1)
        beq t1, t0, acabou2
        jal write
        addi a1, a1, 1
        j loop3
    acabou2:
        li t0, '\n'
        sb t0, 0(a1)
        jal write
        lw ra, 0(sp)         #pega o valor de ra da pilha
        addi sp, sp, 16      #incrementa sp
        ret

#a0 --> endereço que vai salvar os bytes
gets:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw a0, 4(sp)
    mv a1, a0       #move o endereço que vai salvar os bytes pra a1
    li t0, '\n'     #\n
    loop:
    jal read        #leio um byte
    lbu t1, 0(a1)    #carrego esse byte que eu acabei de ler
    beq t1, t0, sai 
    addi a1, a1, 1
    j loop
    sai:
    sb zero, 0(a1)
    lw ra, 0(sp)         #pega o valor de ra da pilha
    lw a0, 4(sp)
    addi sp, sp, 16       #incrementa sp
    ret

exit:
    li a0, 0           #isso daqui é pra finalizar o programa
    li a7, 93          #syscall de exit
    ecall

    




