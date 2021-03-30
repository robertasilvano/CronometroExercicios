; entrada 1: Tempo de preparação - 0h / 1h
; entrada 2: Quantidade de exercicios - 2h / 3h
; entrada 3: Tempo de execução de exercícios - 4h / 5h
; entrada 4: Tempo de descanso entre exercícios - 6h / 7h

.define
	end_tela E000h

.data DDh
	DB 54h, 50h, 3Ah ; TP:
	DB 51h, 54h, 3Ah ; QT:
	DB 54h, 45h, 3Ah ; TE:
	DB 54h, 44h, 3Ah ; TD:

.org 2000h

	call printar

	MVI D, 4h ; move o valor imediato 4h pro registrador D (contador das variáveis de entrada)
	LXI H, 0000h ; move o valor imediato 0h pro registrador H, para zerar o endereço
	
entradas:
	IN 0h ; pega o input da porta 0h (teclado) e coloca no acumulador
	SUI 30h ; subtrai 30h do valor do acumulador (ASCII -> binário puro)
	MOV M, A ; move o valor do acumulador pra o valor apontado por M. Este valor será fixo.
	INX H ; incrementa o valor do registrador B
	MOV M, A ; move o valor do acumulador pra o valor apontado por M. Este valor NÃO será fixo.
	INX H ; incrementa o valor do registrador B
	DCR D ; decrementa o contador de variáveis

CNZ entradas

tempo_preparo:
	LXI H, end_tela+28h ; coloca no registrador H o endereço da tela
	LDA 1h ; carrega no acumulador o valor no endereço 1h (endereço var1 não fixa)
	ADI 30h ; adiciona 30h do valor do acumulador (binário puro -> ASCII)
	MOV M, A ; move o valor do acumulador para a tela
	
	LXI H, 0001h ; coloca no registrador H o endereço da var1 não fixa
	DCR M ; decrementa 1 da memória apontada por HL (endereço var1 não fixa)

	CNZ tempo_preparo

qtd_exercicios:
	LXI H, end_tela+50h; coloca no registrador H o endereço da tela
	LDA 3h ; carrega no acumulador o valor no endereço 3h (endereço var2 não fixa)
	ADI 30h ; adiciona 30h do valor do acumulador (binário puro -> ASCII)
	MOV M, A ; move o valor do acumulador para a tela

	call tempo_exercicio
	call checa_descanso

	call set_valores_iniciais
	
	LXI H, 0003h ; coloca no registrador H o endereço da var2 não fixa
	DCR M ; decrementa 1 da memória apontada por HL (endereço var2 não fixa)	

	CNZ qtd_exercicios

	HLT

tempo_exercicio:
	LXI H, end_tela+78h ; coloca no registrador H o endereço da tela
	LDA 5h ; carrega no acumulador o valor no endereço 5h (enndereço var3 não fixa)
	ADI 30h ; adiciona 30h do valor do acumulador (binário puro -> ASCII)
	MOV M, A ; move o valor do acumulador para a tela
	
	LXI H, 0005h ; coloca no registrador H o endereço da var3 não fixa
	DCR M ; decrementa 1 da memória apontada por HL (endereço var3 não fixa)

	CNZ tempo_exercicio

	RET

checa_descanso:
	; precisa disso para saber se já ta no ultimo exercicio
		 ; se sim, não deve ter tempo de descanso pq já finalizou. então retorna pra função qtd_exercicios
		 ; se não, executa o código do tempo_descanso

	LDA 3h ; carrega no acumulador o valor no endereço 1h (endereço var1 não fixa)
	MVI C, 1h ; move o valor imediato 1h para o registrador C (esse valor representa o ultimo exercicio)
	CMP C ; se estiver no ultimo exercicio, z=1, se não, z=0

	CNZ tempo_descanso


	RET	 

tempo_descanso:
	
	LXI H, end_tela+90h ; coloca no registrador H o endereço da tela
	LDA 7h ; carrega no acumulador o valor no endereço 7h (enndereço var4 não fixa)
	ADI 30h ; adiciona 30h do valor do acumulador (binário puro -> ASCII)
	MOV M, A ; move o valor do acumulador para a tela
	
	LXI H, 0007h ; coloca no registrador H o endereço da var4 não fixa
	DCR M ; decrementa 1 da memória apontada por HL (endereço var4 não fixa)


	CNZ tempo_descanso

	RET

set_valores_iniciais:
	LDA 4h ; carrega valor da var3 fixa (valor inicial) no acumulador 
	LXI H, 0005h ; coloca no registrador o endereço da var3 não fixa
	MOV M, A ; move o valor inicial da var3 fixa para o endereço da var3 não fixa

	LDA 6h ; carrega valor da var4 fixa (valor inicial) no acumulador 
	LXI H, 0007h ; coloca no registrador o endereço da var4 não fixa
	MOV M, A ; move o valor inicial da var3 fixa para o endereço da var4 não fixa
	
	RET

printar:

	LXI D, DDh ; carrega o primeiro endereço do .data no registrador D
	LXI H, end_tela ; carrega o endereço da tela no registrador H
	
	MVI C, 4h ; move o valor imediato 4h pro registrador C
		    ; esse valor é um contador de linhas
	call total_linhas
	
	RET

total_linhas:

	MVI B, 3h ; move o valor imediato 3h pro registrador B
		    ; esse valor é um contador de caracteres
	;aqui tem q incrementar o endereço da tela pra proxima linha mas ainda n sei como rs
	call linha
	
	DCR C ; decrementa o contador de linhas
	CNZ total_linhas ; se ainda tiverem linhas para serem printadas, chama novamente a função

	RET

linha:
	LDAX D ; carrega o valor apontado pelo registrador D no acumulador
	MOV M, A ; move o valor do acumulador (letra) para o endereço de memória apontado por M (endereço da tela)
	
	INR E ; incrementa o endereço apontado por E (endereço das letras)
	INX H ; incrementa o endereço apontado por H (endereço da tela)

	DCR B ; decrementa o contador de caracteres

	CNZ linha

	RET