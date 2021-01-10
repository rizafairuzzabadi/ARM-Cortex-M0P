Index		EQU	0x6	;Array size 
	
			AREA    My_Array, DATA, READWRITE		;Defined area will be placed to the data memory
f_array		SPACE	(Index+1)*4
f_end

			AREA recursive_array, code, readonly
			ENTRY
			THUMB
			ALIGN
__main		FUNCTION
			EXPORT __main
			BL		Factorial		; call Factorial function
stop 		B 		stop

	 
Factorial   MOVS 	r3, #Index		; Load Array Size
			MOVS 	r0, #4			; i = 1 as index value
			MOVS	r2, #1			; for f_array[0] = 1
									;;MOVS	r1,	#0			; 0 for f_array[0]
            LDR	 	r5, =f_array	; Load start address of the allocated space for array
            STR     r2,[r5,r0]      ; f_array[0] = 1
ForLo		CMP 	r2, r3			; Check i < Index
			BGT 	stop			; if not finish loop
									;;PUSH 	{r0}
			ADDS	r0,r0,#4		; j++ for array
			SUBS 	r1,r0,#4		; temp = j-1
									;;POP		{r0}
			LDR		r6, [r5,r1]		; temp2 = f_array[temp]
			MULS 	r6,r2,r6		; temp2 = i * temp2
			STR		r6,[r5, r0]		; f_array[j] = temp2
			ADDS	r2,r2,#1		; i++
			B 		ForLo			; End of the for loop, jump start point
			BX 		LR				; return link register
			
			ENDFUNC
			END