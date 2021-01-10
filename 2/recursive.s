Index		EQU	0x6	;Array size 
	
			AREA    My_Array, DATA, readwrite		;Defined area will be placed to the data memory
x_array		SPACE	(Index+1)*4
x_end

			AREA recursive_array, code, readonly
			ENTRY
			THUMB
			ALIGN
__main		FUNCTION
			EXPORT __main
		
			MOVS 	r3, #Index		; Load Array Size
			MOVS 	r0, #0			; i = 0 as index value
			MOVS 	r6, #0			; second i for 4 bytes
			LDR	 	r5, =x_array	; Load start address of the allocated space for array
			
ForLo		CMP 	r0, r3			; Check i < Index
			BGE 	stop			; if not finish loop
			BL		Factorial		; call Factorial function
			STR 	r2,[r5,r6]		; x[i] = temp
			ADDS	r0,r0,#1		; i++
			ADDS	r0,r0,#4		; i++
			B 		ForLo			; End of the for loop, jump start point
stop 		B 		stop


Factorial	CMP		r0, #2			;if n<2
			BLT 	less			;if true then go to less
			MOVS	r1, #0			;for copying -
			ADDS	r1, r0, r1		;-the i value to temp	
			SUBS 	r0,r0,#1		;n-1
			BL 		Factorial		;call factorial
			MULS 	r1,r3,r1		;n*factorial(n-1)
			MOVS	r2,r0;
			B ending
			
less		MOVS	r2,#1			;temp = 1;
ending		BX		lr		
			
			ENDFUNC
			END
			
			
		
			
		
