stm8/

	#include "mapping.inc"
	#include "STM8S105K.inc"
COUNT EQU 0	
COUNT2 EQU 1
	
	segment 'ram1'
	
	segment 'rom'
main.l
	; initialize SP
	ldw X,#stack_end
	ldw SP,X

	#ifdef RAM0	
	; clear RAM0
ram0_start.b EQU $ram0_segment_start
ram0_end.b EQU $ram0_segment_end
	ldw X,#ram0_start
clear_ram0.l
	clr (X)
	incw X
	cpw X,#ram0_end	
	jrule clear_ram0
	#endif

	#ifdef RAM1
	; clear RAM1
ram1_start.w EQU $ram1_segment_start
ram1_end.w EQU $ram1_segment_end	
	ldw X,#ram1_start
clear_ram1.l
	clr (X)
	incw X
	cpw X,#ram1_end	
	jrule clear_ram1
	#endif

	; clear stack
stack_start.w EQU $stack_segment_start
stack_end.w EQU $stack_segment_end
	ldw X,#stack_start
clear_stack.l
	clr (X)
	incw X
	cpw X,#stack_end	
	jrule clear_stack
	
	mov PD_DDR, #$ff
	mov PD_CR1, #$ff
	
	mov PE_CR2, #$ff
	mov PE_ODR, #$55
	
	
	mov PC_CR2, #$ff
	
	bset EXTI_CR1,#4
	bset EXTI_CR2,#0
	
	RIM 


;;;;;; UNCOMMENT EACH SECTION FOR EACH EXERCISE ;;;;;;

;;;;;; EXERICSE 1 ;;;;;;

;button_press
;	inc COUNT
;	call delay
;	ld a, #100
;	cp a,COUNT
;	jreq execute
;	jra button_press
	
;execute
;		mov PD_ODR, PE_IDR
;		jra infinite_loop

;infinite_loop.l
;	btjf PE_IDR,#5,button_press
;	jra infinite_loop


;;;;;; EXERCISE 2 ;;;;;;

;The following code slightly turns on all LEDs, but it can be
;seen with the naked eye due to the delay called
;however, the concepts of interrupts is clearly understood
; and applied.

infinite_loop.l
	mov PD_ODR, #$00
	jra infinite_loop
	
	
delay
  ld a, #255
  inc COUNT2
  nop
  CP a,COUNT2
  jreq done
  jra delay
	
done
	ret
	
	interrupt NonHandledInterrupt
NonHandledInterrupt.l
	iret

isr_portE
	mov PD_ODR, #$ff
	inc COUNT
	call delay
	ld a, #100
	cp a,COUNT
	iret

isr_portC
	mov PD_ODR, #$56
	inc COUNT
	call delay
	ld a, #100
	cp a,COUNT
	iret
	
	
	segment 'vectit'
	dc.l {$82000000+main}									; reset
	dc.l {$82000000+NonHandledInterrupt}	; trap
	dc.l {$82000000+NonHandledInterrupt}	; irq0
	dc.l {$82000000+NonHandledInterrupt}	; irq1
	dc.l {$82000000+NonHandledInterrupt}	; irq2
	dc.l {$82000000+NonHandledInterrupt}	; irq3
	dc.l {$82000000+NonHandledInterrupt}	; irq4
	dc.l {$82000000+isr_portC}	; irq5
	dc.l {$82000000+NonHandledInterrupt}	; irq6
	dc.l {$82000000+isr_portE}	; irq7
	dc.l {$82000000+NonHandledInterrupt}	; irq8
	dc.l {$82000000+NonHandledInterrupt}	; irq9
	dc.l {$82000000+NonHandledInterrupt}	; irq10
	dc.l {$82000000+NonHandledInterrupt}	; irq11
	dc.l {$82000000+NonHandledInterrupt}	; irq12
	dc.l {$82000000+NonHandledInterrupt}	; irq13
	dc.l {$82000000+NonHandledInterrupt}	; irq14
	dc.l {$82000000+NonHandledInterrupt}	; irq15
	dc.l {$82000000+NonHandledInterrupt}	; irq16
	dc.l {$82000000+NonHandledInterrupt}	; irq17
	dc.l {$82000000+NonHandledInterrupt}	; irq18
	dc.l {$82000000+NonHandledInterrupt}	; irq19
	dc.l {$82000000+NonHandledInterrupt}	; irq20
	dc.l {$82000000+NonHandledInterrupt}	; irq21
	dc.l {$82000000+NonHandledInterrupt}	; irq22
	dc.l {$82000000+NonHandledInterrupt}	; irq23
	dc.l {$82000000+NonHandledInterrupt}	; irq24
	dc.l {$82000000+NonHandledInterrupt}	; irq25
	dc.l {$82000000+NonHandledInterrupt}	; irq26
	dc.l {$82000000+NonHandledInterrupt}	; irq27
	dc.l {$82000000+NonHandledInterrupt}	; irq28
	dc.l {$82000000+NonHandledInterrupt}	; irq29

	end
