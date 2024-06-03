stm8/

	#include "mapping.inc"
	#include "stm8s105k.inc"
	segment 'ram1'
MIN EQU 1
MAX EQU 128
place EQU 0
array1 ds.b 16
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
	
	ldw x, #MIN
	ld A, #1
	
end_loop
	nop
	jra end_loop
infinite_loop.l
	sll MIN
;	cp MIN, MAX
	jreq end_loop
	jra infinite_loop

;;;;;;;;;; Exercise 1	;;;;;;;;;;;;;;;;;
;	MOV TIM2_CR1,#%00000001 ; counter enable ON
;	MOV TIM2_IER,#$00 ; no interrupts
;	MOV TIM2_CCMR1,#%01100000 ; PWM mode 1 + CC1 as output
;	MOV TIM2_CCER1,#%0000000 ; setting the jumper to D4?

;	MOV TIM3_CR1,#%00000001 ; timer on
;	MOV TIM3_PSCR,#$07 ; prescaler x128
;	BSET TIM3_EGR,#0 ; force UEV to update prescaler
;	MOV TIM3_IER,#$01 ; TIM3 interrupt on update enabled
;	BRES TIM3_SR1,#0 ; clear flag
	
;infinite_loop.l
;	ld a, #$4E
;	ld TIM2_ARRH, a ; 20000 -> 00x4E20
;	ld a, #$20
;	ld TIM2_ARRL, a
	
;	ldw x, #$7D0 ; duty cycle
;	ld a, xh		; ^ this is the time the circuit is on
;	ld TIM2_CCR1H, a ; ^ compared to when it is off.
;	ld a, xl
;	ld TIM2_CCR1L, a
;	jra infinite_loop

	interrupt NonHandledInterrupt
NonHandledInterrupt.l
	iret

	segment 'vectit'
	dc.l {$82000000+main}									; reset
	dc.l {$82000000+NonHandledInterrupt}	; trap
	dc.l {$82000000+NonHandledInterrupt}	; irq0
	dc.l {$82000000+NonHandledInterrupt}	; irq1
	dc.l {$82000000+NonHandledInterrupt}	; irq2
	dc.l {$82000000+NonHandledInterrupt}	; irq3
	dc.l {$82000000+NonHandledInterrupt}	; irq4
	dc.l {$82000000+NonHandledInterrupt}	; irq5
	dc.l {$82000000+NonHandledInterrupt}	; irq6
	dc.l {$82000000+NonHandledInterrupt}	; irq7
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
