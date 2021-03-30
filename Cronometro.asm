; entrada 1: Tempo de prepara��o - 0h / 1h
; entrada 2: Quantidade de exercicios - 2h / 3h
; entrada 3: Tempo de execu��o de exerc�cios - 4h / 5h
; entrada 4: Tempo de descanso entre exerc�cios - 6h / 7h

.define
	end_tela E000h

.data DDh
	DB 54h, 50h, 3Ah ; TP:
	DB 51h, 54h, 3Ah ; QT:
	DB 54h, 45h, 3Ah ; TE:
	DB 54h, 44h, 3Ah ; TD:

.org 2000h

	call printar

	MVI D, 4h ; move o valor imediato 4h pro registrador D (contador das vari�veis de entrada)
	LXI H, 0000h ; move o valor imediato 0h pro registrador H, para zerar o endere�o
	
entradas:
	IN 0h ; pega o input da porta 0h (teclado) e coloca no acumulador
	SUI 30h ; subtrai 30h do valor do acumulador (ASCII -> bin�rio puro)
	MOV M, A ; move o valor do acumulador pra o valor apontado por M. Este valor ser� fixo.
	INX H ; incrementa o valor do registrador B
	MOV M, A ; move o valor do acumulador pra o valor apontado por M. Este valor N�O ser� fixo.
	INX H ; incrementa o valor do registrador B
	DCR D ; decrementa o contador de vari�veis

CNZ entradas

tempo_preparo:
	LXI H, end_tela+28h ; coloca no registrador H o endere�o da tela
	LDA 1h ; carrega no acumulador o valor no endere�o 1h (endere�o var1 n�o fixa)
	ADI 30h ; adiciona 30h do valor do acumulador (bin�rio puro -> ASCII)
	MOV M, A ; move o valor do acumulador para a tela
	
	LXI H, 0001h ; coloca no registrador H o endere�o da var1 n�o fixa
	DCR M ; decrementa 1 da mem�ria apontada por HL (endere�o var1 n�o fixa)

	CNZ tempo_preparo

qtd_exercicios:
	LXI H, end_tela+50h; coloca no registrador H o endere�o da tela
	LDA 3h ; carrega no acumulador o valor no endere�o 3h (endere�o var2 n�o fixa)
	ADI 30h ; adiciona 30h do valor do acumulador (bin�rio puro -> ASCII)
	MOV M, A ; move o valor do acumulador para a tela

	call tempo_exercicio
	call checa_descanso

	call set_valores_iniciais
	
	LXI H, 0003h ; coloca no registrador H o endere�o da var2 n�o fixa
	DCR M ; decrementa 1 da mem�ria apontada por HL (endere�o var2 n�o fixa)	

	CNZ qtd_exercicios

	HLT

tempo_exercicio:
	LXI H, end_tela+78h ; coloca no registrador H o endere�o da tela
	LDA 5h ; carrega no acumulador o valor no endere�o 5h (enndere�o var3 n�o fixa)
	ADI 30h ; adiciona 30h do valor do acumulador (bin�rio puro -> ASCII)
	MOV M, A ; move o valor do acumulador para a tela
	
	LXI H, 0005h ; coloca no registrador H o endere�o da var3 n�o fixa
	DCR M ; decrementa 1 da mem�ria apontada por HL (endere�o var3 n�o fixa)

	CNZ tempo_exercicio

	RET

checa_descanso:
	; precisa disso para saber se j� ta no ultimo exercicio
		 ; se sim, n�o deve ter tempo de descanso pq j� finalizou. ent�o retorna pra fun��o qtd_exercicios
		 ; se n�o, executa o c�digo do tempo_descanso

	LDA 3h ; carrega no acumulador o valor no endere�o 1h (endere�o var1 n�o fixa)
	MVI C, 1h ; move o valor imediato 1h para o registrador C (esse valor representa o ultimo exercicio)
	CMP C ; se estiver no ultimo exercicio, z=1, se n�o, z=0

	CNZ tempo_descanso


	RET	 

tempo_descanso:
	
	LXI H, end_tela+90h ; coloca no registrador H o endere�o da tela
	LDA 7h ; carrega no acumulador o valor no endere�o 7h (enndere�o var4 n�o fixa)
	ADI 30h ; adiciona 30h do valor do acumulador (bin�rio puro -> ASCII)
	MOV M, A ; move o valor do acumulador para a tela
	
	LXI H, 0007h ; coloca no registrador H o endere�o da var4 n�o fixa
	DCR M ; decrementa 1 da mem�ria apontada por HL (endere�o var4 n�o fixa)


	CNZ tempo_descanso

	RET

set_valores_iniciais:
	LDA 4h ; carrega valor da var3 fixa (valor inicial) no acumulador 
	LXI H, 0005h ; coloca no registrador o endere�o da var3 n�o fixa
	MOV M, A ; move o valor inicial da var3 fixa para o endere�o da var3 n�o fixa

	LDA 6h ; carrega valor da var4 fixa (valor inicial) no acumulador 
	LXI H, 0007h ; coloca no registrador o endere�o da var4 n�o fixa
	MOV M, A ; move o valor inicial da var3 fixa para o endere�o da var4 n�o fixa
	
	RET

printar:

	LXI D, DDh ; carrega o primeiro endere�o do .data no registrador D
	LXI H, end_tela ; carrega o endere�o da tela no registrador H
	
	MVI C, 4h ; move o valor imediato 4h pro registrador C
		    ; esse valor � um contador de linhas
	call total_linhas
	
	RET

total_linhas:

	MVI B, 3h ; move o valor imediato 3h pro registrador B
		    ; esse valor � um contador de caracteres
	;aqui tem q incrementar o endere�o da tela pra proxima linha mas ainda n sei como rs
	call linha
	
	DCR C ; decrementa o contador de linhas
	CNZ total_linhas ; se ainda tiverem linhas para serem printadas, chama novamente a fun��o

	RET

linha:
	LDAX D ; carrega o valor apontado pelo registrador D no acumulador
	MOV M, A ; move o valor do acumulador (letra) para o endere�o de mem�ria apontado por M (endere�o da tela)
	
	INR E ; incrementa o endere�o apontado por E (endere�o das letras)
	INX H ; incrementa o endere�o apontado por H (endere�o da tela)

	DCR B ; decrementa o contador de caracteres

	CNZ linha

	RET