LIMIT	EQU	0x10	;Array size 78
	
			AREA    My_Array, DATA, READWRITE		;Defined area will be placed to the data memory
p_array		SPACE	(LIMIT+1)*4						;primeNumbers
p_end

i_array		SPACE	LIMIT+1						;isPrimeNumber
i_end



			AREA Eratosthenes, code, readonly
			ENTRY
			THUMB
			ALIGN
__main		FUNCTION
			EXPORT __main
			BL		SieveOfEratosthenes		; call Factorial function
stop 		B 		stop

	 
SieveOfEratosthenes   	MOVS 	r0,#LIMIT		; Load Array Size
						LDR		r6,=i_array		; Load start address of the allocated space for array
						LDR		r5,=p_array		; Load start address of the allocated space for array
						
						MOVS 	r1, #0			; int i = 0;
						
						
ForOne					CMP		r1, r0			; i <= 0  to limit
						BGT 	Two
						LDR		r2, =0			; for putting zeros in primeNumbers
						MOVS 	r3, #4			; int temp = 4 for multiplication
						MULS	r3, r1, r3		; 4 * i for array[i]
						STR		r2,[r5,r3]		; primeNumbers[i] = temp
						LDR		r3,=1			; temp = TRUE
						STRB 	r3,[r6,r1]		; isPrimeNumber[i] = true
						ADDS  	r1, r1, #1		;
						B ForOne
Two						LDR		r1,=2			; i = 2
						
ForTwo					MOVS 	r3, r1			; copying r1 to r3
												;MOVS	r3, #0			;for copying -
												;ADDS	r3, r1, r3		;-the i value to temp
						PUSH	{r1}			; save the old value of r1
						MULS	r1,r1,r1		; i * i
						CMP		r1, r0			; i*i <= limit
						BGT		Three			; jump to three
						MOVS	r4,r3			; copying r3 to r4
						LDRB 	r3,[r6,r3]		; temp = isPrimeNumber[i] 
						CMP 	r3, #1			; if isPrimeNumber[i]
						BNE		ending			; jump to ending
ForTwopOne				PUSH	{r2}
						SUBS 	r2, r4, #2		; r2 = (i - 2) ->
						MULS	r2, r4, r2		; -> r2 = r1*r2
						ADDS	r2, r4, r2		; j = i*i + (*r2*i)
						CMP		r2, r0			; j <= limit
						BGT		FTExit			; jump to FTExit
						LDR		r3,=4			; temp = 4 for multiplication
						MULS	r3, r2, r3		; 4 * i for array[i]
						LDR 	r7,=0			; temp3 = false
						STRB	r7,[r6,r3]		; isPrimeNumber[j] = false
						POP		{r2}
						ADDS	r2,r2,#1		;
						B ForTwopOne			; jump to ForTwopOne
FTExit					POP		{r1}			; get the old value of r1
						B 		ending			; jump to ending
ending					ADDS	r1, r1, #1		; j++
						B ForTwo				; jump back to fortwo
						
Three					LDR		r1, =2			; i = 2
ForThree				CMP		r1, r0			; i <= 2 to limit
						BGT 	stop			; stop the function
						LDRB	r3,[r6,r1]		; temp = isPrimeNumber[i]
						CMP		r3,#1			; if isPrimeNumber[i] is TRUE
						BNE 	ending2			; jump to ending if not equal
						STR		r1,[r5,r2]		; store the value of r1 to p_array
						ADDS	r2,r2,#4		; index++
						B 		ending2			; jump to ending
ending2					ADDS	r1,r1,#1		; i++
						B ForThree				; jump back to forthree
						BX 		LR
						
						ENDFUNC
						END