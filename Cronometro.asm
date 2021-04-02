; entrada 1: Tempo de preparação - 0h / 1h
; entrada 2: Quantidade de exercicios - 2h / 3h
; entrada 3: Tempo de execução de exercícios - 4h / 5h
; entrada 4: Tempo de descanso entre exercícios - 6h / 7h

.define
	end_texto E000h
	end_num E004h
	soma_tela 25h

.data DDh
	DB 54h, 50h, 3Ah ; TP:
	DB 51h, 45h, 3Ah ; QE:
	DB 54h, 45h, 3Ah ; TE:
	DB 54h, 44h, 3Ah ; TD:

.org 2000h

	call printar

	MVI D, 4h ; move o valor imediato 4h pro registrador D (contador das variáveis de entrada)
	LXI H, 0000h ; move o valor imediato 0h pro registrador H, para zerar o endereço

entradas:
	CALL delay
	CALL aguarda_entrada
	IN 0h ; pega o input da porta 0h (teclado) e coloca no acumulador
	SUI 30h ; subtrai 30h do valor do acumulador (ASCII -> binário puro)
	MOV M, A ; move o valor do acumulador pra o valor apontado por M. Este valor será fixo.
	INX H ; incrementa o valor do registrador B
	MOV M, A ; move o valor do acumulador pra o valor apontado por M. Este valor NÃO será fixo.
	INX H ; incrementa o valor do registrador B
	DCR D ; decrementa o contador de variáveis

	CNZ entradas

	CALL tempo_preparo

delay:
	
	MVI B, 2Fh ; move o valor imediato 2Fh para o registrador B
	decB: 
		MVI C, FFh ; move o valor imediato FFh para o registrador C
		decC: DCR C ; decrementa o registrador C
		JNZ decC ; se ainda não estiver zerado, chama a função de decrementar C de novo
	
	DCR B ; decrementa o registrador B
	CNZ decB ; se ainda não estiver zerado, chama a função de decrementar B de novo

	RET


aguarda_entrada:
	IN 0h ; pega a entrada na porta 0h e coloca no acumulador
	MVI C, 0h ; move o valor imediato 0h para o registrador C

	CMP C ; compara o valor do acumulador e do registrador C
		; se forem iguais, ainda não teve input, e portando chama essa função de novo
		; se não forem iguais, já foi dado input então retorna

	JZ aguarda_entrada 

	RET

tempo_preparo:
	LXI H, end_num ; coloca no registrador H o endereço da tela
	LDA 1h ; carrega no acumulador o valor no endereço 1h (endereço var1 não fixa)
	ADI 30h ; adiciona 30h do valor do acumulador (binário puro -> ASCII)
	MOV M, A ; move o valor do acumulador para a tela

	CALL delay
	
	LXI H, 0001h ; coloca no registrador H o endereço da var1 não fixa
	DCR M ; decrementa 1 da memória apontada por HL (endereço var1 não fixa)

	CNZ tempo_preparo

	CALL f_alarme

qtd_exercicios:
	LXI H, end_num+28h; coloca no registrador H o endereço da tela
	LDA 3h ; carrega no acumulador o valor no endereço 3h (endereço var2 não fixa)
	ADI 30h ; adiciona 30h do valor do acumulador (binário puro -> ASCII)
	MOV M, A ; move o valor do acumulador para a tela

	CALL tempo_exercicio
	CALL f_alarme
	CALL checa_descanso
	CALL checa_alarme

	CALL set_valores_iniciais
	
	LXI H, 0003h ; coloca no registrador H o endereço da var2 não fixa
	DCR M ; decrementa 1 da memória apontada por HL (endereço var2 não fixa)	

	CNZ qtd_exercicios

	CALL delay

	CALL f_alarme

	HLT

tempo_exercicio:
	LXI H, end_num+50h ; coloca no registrador H o endereço da tela
	LDA 5h ; carrega no acumulador o valor no endereço 5h (enndereço var3 não fixa)
	ADI 30h ; adiciona 30h do valor do acumulador (binário puro -> ASCII)
	MOV M, A ; move o valor do acumulador para a tela

	CALL delay
	
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
	
	LXI H, end_num+78h ; coloca no registrador H o endereço da tela
	LDA 7h ; carrega no acumulador o valor no endereço 7h (enndereço var4 não fixa)
	ADI 30h ; adiciona 30h do valor do acumulador (binário puro -> ASCII)
	MOV M, A ; move o valor do acumulador para a tela
	
	CALL delay

	LXI H, 0007h ; coloca no registrador H o endereço da var4 não fixa
	DCR M ; decrementa 1 da memória apontada por HL (endereço var4 não fixa)

	CNZ tempo_descanso

	RET

checa_alarme:
	; precisa saber se já ta no ultimo exercício
		; se não, chama o alarme e depois retorna para qtd_exercicios
		; se sim, não chama o alarme e depois retorna para qtd_exercicios

	LDA 3h ; carrega no acumulador o valor no endereço 1h (endereço var1 não fixa)
	MVI C, 1h ; move o valor imediato 1h para o registrador C (esse valor representa o ultimo exercicio)
	CMP C ; se estiver no ultimo exercicio, z=1, se não, z=0

	CNZ f_alarme
	
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
	LXI H, end_texto
	
	MVI C, 4h ; move o valor imediato 4h pro registrador C
		    ; esse valor é um contador de linhas
	call linha
	
	RET

linha:
	
	MVI B, 3h ; move o valor imediato 3h pro registrador B
		    ; esse valor é um contador de caracteres
	
	call caracter

	MOV A, L ; move o valor do registrador L (4 bits finais do endereço da tela) para o acumulador
	ADI soma_tela ; incrementa o valor da tela para a próxima linha
	MOV L, A ; move o valor do acumulador para o registrador L, tendo então o endereço da próxima linha em HL
	
	DCR C ; decrementa o contador de linhas
	CNZ linha ; se ainda tiverem linhas para serem printadas, chama novamente a função

	RET

caracter:
	LDAX D ; carrega o valor apontado pelo registrador D no acumulador
	MOV M, A ; move o valor do acumulador (letra) para o endereço de memória apontado por M (endereço da tela)
	
	INR E ; incrementa o endereço apontado por E (endereço das letras)
	INX H ; incrementa o endereço apontado por H (endereço da tela)

	DCR B ; decrementa o contador de caracteres

	CNZ caracter

	RET


f_alarme:
	
	MVI A, FFh ; move o valor imediato FFh para o acumulador
	OUT 0h ; coloca na saída 0h o valor do acumulador (acende todos os leds)

	CALL delay

	MVI A, 0h ; move o valor imediato 0h para o acumulador
	OUT 0h ; coloca na saída 0h o valor do acumulador (apaga todos os leds)

	RET