;*******************************************************************************
;@file				 Main.s
;@project		     Microprocessor Systems Term Project
;@date
;
;@PROJECT GROUP
;@groupno
;@member1
;@member2
;@member3
;@member4
;@member5
;*******************************************************************************
;*******************************************************************************
;@section 		INPUT_DATASET
;*******************************************************************************

;@brief 	This data will be used for insertion and deletion operation.
;@note		The input dataset will be changed at the grading. 
;			Therefore, you shouldn't use the constant number size for this dataset in your code. 
				AREA     IN_DATA_AREA, DATA, READONLY
IN_DATA			DCD		0x10, 0x20, 0x15, 0x65, 0x25, 0x01, 0x01, 0x12, 0x65, 0x25, 0x85, 0x46, 0x10, 0x00
END_IN_DATA

;@brief 	This data contains operation flags of input dataset. 
;@note		0 -> Deletion operation, 1 -> Insertion 
				AREA     IN_DATA_FLAG_AREA, DATA, READONLY
IN_DATA_FLAG	DCD		0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x02
END_IN_DATA_FLAG


;*******************************************************************************
;@endsection 	INPUT_DATASET
;*******************************************************************************

;*******************************************************************************
;@section 		DATA_DECLARATION
;*******************************************************************************

;@brief 	This part will be used for constant numbers definition.
NUMBER_OF_AT	EQU		20									; Number of Allocation Table
AT_SIZE			EQU		NUMBER_OF_AT*4						; Allocation Table Size


DATA_AREA_SIZE	EQU		AT_SIZE*32*2						; Allocable data area
															; Each allocation table has 32 Cell
															; Each Cell Has 2 word (Value + Address)
															; Each word has 4 byte
ARRAY_SIZE		EQU		AT_SIZE*32							; Allocable data area
															; Each allocation table has 32 Cell
															; Each Cell Has 1 word (Value)
															; Each word has 4 byte
LOG_ARRAY_SIZE	EQU      AT_SIZE*32*3						; Log Array Size
															; Each log contains 3 word
															; 16 bit for index
															; 8 bit for error_code
															; 8 bit for operation
															; 32 bit for data
															; 32 bit for timestamp in us

;//-------- <<< USER CODE BEGIN Constant Numbers Definitions >>> ----------------------															
							


;//-------- <<< USER CODE END Constant Numbers Definitions >>> ------------------------	

;*******************************************************************************
;@brief 	This area will be used for global variables.
				AREA     GLOBAL_VARIABLES, DATA, READWRITE		
				ALIGN	
TICK_COUNT		SPACE	 4									; Allocate #4 byte area to store tick count of the system tick timer.
FIRST_ELEMENT  	SPACE    4									; Allocate #4 byte area to store the first element pointer of the linked list.
INDEX_INPUT_DS  SPACE    4									; Allocate #4 byte area to store the index of input dataset.
INDEX_ERROR_LOG SPACE	 4									; Allocate #4 byte aret to store the index of the error log array.
PROGRAM_STATUS  SPACE    4									; Allocate #4 byte to store program status.
															; 0-> Program started, 1->Timer started, 2-> All data operation finished.
;//-------- <<< USER CODE BEGIN Global Variables >>> ----------------------															
							


;//-------- <<< USER CODE END Global Variables >>> ------------------------															

;*******************************************************************************

;@brief 	This area will be used for the allocation table
				AREA     ALLOCATION_TABLE, DATA, READWRITE		
				ALIGN	
__AT_Start
AT_MEM       	SPACE    AT_SIZE							; Allocate #AT_SIZE byte area from memory.
__AT_END

;@brief 	This area will be used for the linked list.
				AREA     DATA_AREA, DATA, READWRITE		
				ALIGN	
__DATA_Start
DATA_MEM        SPACE    DATA_AREA_SIZE						; Allocate #DATA_AREA_SIZE byte area from memory.
__DATA_END

;@brief 	This area will be used for the array. 
;			Array will be used at the end of the program to transform linked list to array.
				AREA     ARRAY_AREA, DATA, READWRITE		
				ALIGN	
__ARRAY_Start
ARRAY_MEM       SPACE    ARRAY_SIZE						; Allocate #ARRAY_SIZE byte area from memory.
__ARRAY_END

;@brief 	This area will be used for the error log array. 
				AREA     ARRAY_AREA, DATA, READWRITE		
				ALIGN	
__LOG_Start
LOG_MEM       	SPACE    LOG_ARRAY_SIZE						; Allocate #DATA_AREA_SIZE byte area from memory.
__LOG_END

;//-------- <<< USER CODE BEGIN Data Allocation >>> ----------------------															
							


;//-------- <<< USER CODE END Data Allocation >>> ------------------------															

;*******************************************************************************
;@endsection 	DATA_DECLARATION
;*******************************************************************************

;*******************************************************************************
;@section 		MAIN_FUNCTION
;*******************************************************************************

			
;@brief 	This area contains project codes. 
;@note		You shouldn't change the main function. 				
				AREA MAINFUNCTION, CODE, READONLY
				ENTRY
				THUMB
				ALIGN 
__main			FUNCTION
				EXPORT __main
				BL	Clear_Alloc					; Call Clear Allocation Function.
				BL  Clear_ErrorLogs				; Call Clear ErrorLogs Function.
				BL	Init_GlobVars				; Call Initiate Global Variable Function.
				BL	SysTick_Init				; Call Initialize System Tick Timer Function.
				LDR R0, =PROGRAM_STATUS			; Load Program Status Variable Addresses.
LOOP			LDR R1, [R0]					; Load Program Status Variable.
				CMP	R1, #2						; Check If Program finished.
				BNE LOOP						; Go to loop If program do not finish.
STOP			B	STOP						; Infinite loop.
				
				ENDFUNC
			
;*******************************************************************************
;@endsection 		MAIN_FUNCTION
;*******************************************************************************				

;*******************************************************************************
;@section 			USER_FUNCTIONS
;*******************************************************************************

;@brief 	This function will be used for System Tick Handler
SysTick_Handler	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Handler >>> ----------------------															
				EXPORT SysTick_Handler
				LDR R1, =TICK_COUNT						;Load address of the TICK_COUNT
				LDR R2,[R1]								;Load value of the TICK_COUNT
				ADDS R2,R2,#1							;Increase TICK_COUNT value by one
				STR	R2,[R1]								;Store the increased value to memory
				
				LDR R3, =IN_DATA						;Load start address of the input data array
				LDR R1, =INDEX_INPUT_DS					;Load address of the input data INDEX
				LDR R2,[R1]								;R2 = Index of Input Dataset Array
				LDR R0,[R3,R2]							;R0 = input data value
				LDR R4, =IN_DATA_FLAG					;Load start address of the input data flag array
				LDR R5,[R4,R2]							;R5 = input data flag representing the operation
				MOV R6,R0								;Save input data value to R6 for after use
				
				push {lr}								;Save return address to stack
				
REMOVE			CMP R5,#0								;Compare operation code with zero
				BNE INSERT								;If operation code is not zero branch to insert
				BL Remove								;If operation code is zero call Remove function with R0 value parameter
				B ERRCHECK								;After return from function go to error check, R0 register now holds the error code
				
INSERT			CMP R5,#1								;Compare operation code with one
				BNE L2ARR								;If operation code is not one branch to link2array
				BL Insert								;If operation code is one call Insert function with R0 value parameter
				B ERRCHECK								;After return from function go to error check, R0 register now holds the error code
				
L2ARR			MOVS R0,#6								;If operation code is not valid after last comparison error code will be six
				CMP R5,#2								;Compare operation code with two
				BNE ERRCHECK							;If operation code is not two branch to ERRCHECK.(Operation is not found error)
				BL LinkedList2Arr						;If operation code is two call LinkedList2Arr function, R0 register now holds the error code 
				
ERRCHECK		CMP R0,#0								;Compare error code with zero 
				BEQ	SKIPERR								;If error code is zero skip write error log
				MOV R1,R0								;R1 -> Error Code
				MOV R0,R2								;R0 -> Index of Input Dataset Array							 
				MOV R2,R5								;R2 -> Operation (Insertion / Deletion / LinkedList2Array)
				MOV R3,R6							    ;R3 -> Data
				BL WriteErrorLog						;Call WriteErrorLog with R0,R1,R2,R3 parameters
				
				
SKIPERR			LDR R1, =INDEX_INPUT_DS					;Load address of the input data set index
				LDR R2,[R1]								;R2 = Index of Input Dataset Array
				ADDS R2,R2,#4							;Increase INDEX_INPUT_DS by 4 (4 bytes = 32-bit integer)
				STR	R2,[R1]								;Store Index value to memory
				
				;Now check if the program reached to the end of the input data
				LDR R1, =END_IN_DATA					;Load end address of the input data set index	
				LDR R3, =IN_DATA						;Load start address of the input data set index
				ADD R3,R2								;Add increased index value to start address of the input data 
				CMP	R3,R1								;Compare start address + index with end address
				BLT	NEXT								;If start address + index is less then end address, go for next value
				BL SysTick_Stop							;If not, input data is finished so stop the SysTick
				
NEXT			POP {r7}								;Pop old return address
				MOV lr,r7								;restore return address
				BX LR	
;//-------- <<< USER CODE END System Tick Handler >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to initiate System Tick Handler
SysTick_Init	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Timer Initialize >>> ----------------------															
				LDR R0, =0xE000E010						;Load address of the SysTick Control and Status Register
				LDR R1, =0X00000007						;Load SysTick Control value
				STR R1, [R0]							;Enable the counter, Enable Systick exception request, select processor as clock source
				LDR R0, =0xE000E014						;Load address of the SysTick Reload Value Register
														;Period Of the System Tick Timer Interrupt: 744 탎
														;CPU clock period: 0.03125 탎
														;Period Of the System Tick Timer Interrupt = (1 + Reload value) * CPU clock period
														;744 탎 = (1 + Reload Value) * 0.03125 탎
				LDR R1, =0X005CFF						;Load reload value should be 23,807 in decimal 5CFF in hex
				STR R1, [R0]							;Store reload value as
				LDR R0, =PROGRAM_STATUS
				MOVS R1,#1
				STR R1, [R0]
				BX LR
;//-------- <<< USER CODE END System Tick Timer Initialize >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to stop the System Tick Timer
SysTick_Stop	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Timer Stop >>> ----------------------	
				LDR R0, =0xE000E010						;Load address of the SysTick Control and Status Register
				LDR R1, =0X00000004						;Load SysTick Control value
				STR R1, [R0]							;Disable the counter, Disable Systick exception request
				
				LDR R0, =PROGRAM_STATUS
				MOVS R1,#2
				STR R1, [R0]
				BX LR
;//-------- <<< USER CODE END System Tick Timer Stop >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to clear allocation table
Clear_Alloc		FUNCTION			
;//-------- <<< USER CODE BEGIN Clear Allocation Table Function >>> ----------------------															
				LDR R0, =AT_MEM
				LDR R1, =AT_SIZE
				MOVS R3,#0			;i=0
				MOVS R4,#0
L1				STR R4,[R0,R3]		;allocationtable[i]=0
				ADDS R3,R3,#4		;i=i+1
				CMP	R1, R3			;compare R1 with R3			
				BGT L1				;Branch if R1 > R3
				BX LR
;//-------- <<< USER CODE END Clear Allocation Table Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************		

;@brief 	This function will be used to clear error log array
Clear_ErrorLogs	FUNCTION			
;//-------- <<< USER CODE BEGIN Clear Error Logs Function >>> ----------------------															
				LDR R0, =LOG_MEM
				LDR R1, =LOG_ARRAY_SIZE
				MOVS R3,#0
				MOVS R4,#0
L2				STR R4,[R0,R3]
				ADDS R3,R3,#4
				CMP	R1, R3							
				BGT L2
				BX LR
;//-------- <<< USER CODE END Clear Error Logs Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************

;@brief 	This function will be used to initialize global variables
Init_GlobVars	FUNCTION			
;//-------- <<< USER CODE BEGIN Initialize Global Variables >>> ----------------------															
				MOVS	R0,#0
				LDR R1, =TICK_COUNT
				LDR R2, =INDEX_INPUT_DS  
				LDR R3, =INDEX_ERROR_LOG 
				LDR R4, =PROGRAM_STATUS
				LDR R5, =FIRST_ELEMENT
				STR R0,[R1]
				STR R0,[R2]
				STR R0,[R3]
				STR R0,[R4]
				STR R0,[R5]
				BX LR
;//-------- <<< USER CODE END Initialize Global Variables >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************	

;@brief 	This function will be used to allocate the new cell 
;			from the memory using the allocation table.
;@return 	R0 <- The allocated area address
Malloc			FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Handler >>> ----------------------	
				
;//-------- <<< USER CODE END System Tick Handler >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used for deallocate the existing area
;@param		R0 <- Address to deallocate
Free			FUNCTION			
;//-------- <<< USER CODE BEGIN Free Function >>> ----------------------
				
;//-------- <<< USER CODE END Free Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to insert data to the linked list
;@param		R0 <- The data to insert
;@return    R0 <- Error Code
Insert			FUNCTION			
;//-------- <<< USER CODE BEGIN Insert Function >>> ----------------------															
				MOVS	R0,#1
				
				BX LR
;//-------- <<< USER CODE END Insert Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to remove data from the linked list
;@param		R0 <- the data to delete
;@return    R0 <- Error Code
Remove			FUNCTION			
;//-------- <<< USER CODE BEGIN Remove Function >>> ----------------------															
				MOVS	R0,#1
				LDR		R1, =FIRST_ELEMENT 	;Load address pointer of first element
				LDR 	R1, [R1]			;R1 having base address of head
				CMP		R1, #0				;Check if head is NULL
				BNE		NoErrorThree		;Skips to NoErrorOne if not equal
				MOVS	R0, #3				;R0 = 3 (indicating The Linked List is empty Error)
				BEQ		Return				;Direct return with new R0 Error Arg.
NoErrorThree	LDR		R2, [R0,#0]			;R2 = argument->data
				LDR		R3, [R1,#0]			;R3 = head->data
				LDR 	R4, R1				;R4 as temp = head
				CMP		R2, R3				;Check if head equals the argument data
				BNE		Check				;Branch to Skip if Equal
				LDR		R3, [R3,#4]			;R3 = head->next
				STR		R3, [R1] 			;Change first_element to next
				BL		Free				;Call Free function with R0 value parameter
				B		Return				;Branch to Return to skip next instructions
Check			MOVS	R5, R4				;R5 as prev = temp
				LDR		R4, [R4,#4]			;temp = temp->next
				CMP		R4, #0				;Check if temp is NULL
				BNE		NoErrorFour			;Continues the function if not equal
				MOVS	R0, #4				;R0 = 4 (indicating the element isn't found Error)
				BEQ		Return				;Direct return with new R0 Error Arg.
NoErrorFour		LDR		R3, [R4,#0]			;R3 = temp->data
				CMP 	R2, R3				;Compare temp->data and arg->data
				BNE		Check				;Go back to check if equal
				LDR		R5, [R5,#4]			;R5 = R5->next	(prev)
				MOVS 	R0, R5				;R0 = temp
				LDR		R4, [R4,#4]			;R4 = R4->next	(temp)
				MOVS	R4, R5				;prev->next = temp->next // R5 = R4
				BL		Free				;Call Free function with R0 value parameter
				MOVS	R0, #0				;After freeing, R0 = 0 to indicate no error's been found
Return			BX LR						;Return R0
;//-------- <<< USER CODE END Remove Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to clear the array and copy the linked list to the array
;@return	R0 <- Error Code
LinkedList2Arr	FUNCTION			
;//-------- <<< USER CODE BEGIN Linked List To Array >>> ----------------------															
				MOVS	R0,#1
				
				BX LR
;//-------- <<< USER CODE END Linked List To Array >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to write errors to the error log array.
;@param		R0 -> Index of Input Dataset Array
;@param     R1 -> Error Code 
;@param     R2 -> Operation (Insertion / Deletion / LinkedList2Array)
;@param     R3 -> Data
WriteErrorLog	FUNCTION			
;//-------- <<< USER CODE BEGIN Write Error Log >>> ----------------------															
				LDR R4,=LOG_MEM							;Load address of the Error Log Memory
				LDR R5,=INDEX_ERROR_LOG					;Load address of the Error Log INDEX
				LDR R7,=__LOG_END						;Load end address of the Error Log Memory
				LDR R6,[R5]								;Load value of the Error Log INDEX
				ADD	R4,R6								;R4 = Start address of the LOG_MEM + INDEX
				CMP	R4,R7								;Compare R4 with end address of the Error Log Memory
				BGE	NOSPACE								;If there is no space left in Error Log Memory do nothing, return
				LDR R4,=LOG_MEM							;R4 is again address of the Error Log Memory
				STRH R0, [R4, R6]						;Store halfword since Index of Input Dataset Array will be stored in 16-bits
				ADDS R6,R6,#2							;Increase offset value by 2 since 2 bytes of data written in previous line
				STRB R1, [R4, R6]						;Store byte since Error Code will be stored in 8-bits
				ADDS R6,R6,#1							;Increase offset value by 1
				STRB R2, [R4, R6]						;Store byte since Operation Code will be stored in 8-bits
				ADDS R6,R6,#1							;Increase offset value by 1
				STR R3, [R4, R6]						;Store word since Data is 32-bits
				ADDS R6,R6,#4							;Increase offset value by 4
				push {lr}								;Save return address to stack
				BL GetNow								;Call GetNow function, R0 register now holds the Timestamp value
				POP {r7}								;Pop old return address
				MOV lr,r7								;restore return address
				STR R0, [R4, R6]						;Store word since Timestamp is 32-bits
				ADDS R6,R6,#4							;Increase offset value by 4
				STR R6,[R5]								;Store increased offset value as Error Log INDEX
NOSPACE							
				BX LR									;return
;//-------- <<< USER CODE END Write Error Log >>> ------------------------				
				ENDFUNC
				
;@brief 	This function will be used to get working time of the System Tick timer
;@return	R0 <- Working time of the System Tick Timer (in us).			
GetNow			FUNCTION			
;//-------- <<< USER CODE BEGIN Get Now >>> ----------------------															
				LDR R1, =TICK_COUNT						;Load address of the TICK_COUNT
				LDR R0,[R1]								;Return value = TICK_COUNT
				LDR R2,=744								;R2 -> 744
				MULS R0,R2,R0							;Return value = TICK_COUNT * 744
				LDR R1, =0xE000E018						;Load address of the SysTick Current Value Register
				LDR R2,[R1]								;Load value of the SysTick Current Value Register
				LDR R1, =0xE000E014						;Load address of the SysTick Reload Value Register
				LDR R3,[R1]								;Load value of the SysTick Reload Value Register
				SUBS R3,R3,R2							;R3 = Reload value - Current Value . This value is, how many clock cycles passed after the last interrupt
				LSRS R3,#5								;Divide by 2^5 which is same as multipliying with 0.03125 our CPU clock period
				ADD R0,R0,R3							;Return value = TICK_COUNT * 744 + (Reload value - Current Value)*0.03125
				BX LR									;Return
;//-------- <<< USER CODE END Get Now >>> ------------------------
				ENDFUNC
				
;*******************************************************************************	

;//-------- <<< USER CODE BEGIN Functions >>> ----------------------															


;//-------- <<< USER CODE END Functions >>> ------------------------

;*******************************************************************************
;@endsection 		USER_FUNCTIONS
;*******************************************************************************
				ALIGN
				END		; Finish the assembly file
				
;*******************************************************************************
;@endfile 			main.s
;*******************************************************************************				

