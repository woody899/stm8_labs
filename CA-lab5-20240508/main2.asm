stm8/

	#include "mapping.inc"
	#include "stm8s105k.inc"
	
	segment 'ram1'
counter DS.W
	
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
	
init
	;E5 as interrupt with pullup
	bset PE_CR2,#5
	mov PE_CR1,#$ff
	bset EXTI_CR2,#1 ;falling edge
	
	;timer 2 setup
	MOV TIM2_CR1,#%00000001 ; counter enable OFF
	MOV TIM2_IER,#$00 ; no interrupts are required for PWM
	MOV TIM2_CCMR1,#%01100000 ; PWM mode 1 + CC1 as output
	MOV TIM2_CCER1,#%00000001 ; CC1 output disabled
	MOV TIM2_PSCR, #$07 ;prescaler x128
	MOV TIM2_ARRH, #$06
	MOV TIM2_ARRL, #$1A
	MOV TIM2_CCR1H, #$00 ;5% duty = 5% of ARR = 78.1 or 78
	MOV TIM2_CCR1L, #$4E
	
	
	;timer 3 setup for 3 seconds
	MOV TIM3_CR1,#%00000000 ; TIM3 OFF
	MOV TIM3_PSCR,#$07 ; prescaler x128
	BSET TIM3_EGR,#0 ; force UEV to update prescaler
	MOV TIM3_IER,#$01 ; TIM3 interrupt on update enabled
	MOV TIM3_ARRH, #$B7			;3 * 2MHz = 6 MHz, divide by 128
	MOV TIM3_ARRL, #$1B
	
	rim
	
	ldw y,#0
	ldw counter, y
infinite_loop.l
	MOV TIM3_CR1,#%00000001
	wfi
	jra infinite_loop
	
is_max
	ldw y,#0
	ldw counter, y
	MOV TIM2_CCR1H, #$00 ;5% duty = 5% of ARR = 78.1 or 78
	MOV TIM2_CCR1L, #$4E
	bres TIM3_SR1,#0
	iret
	

	interrupt NonHandledInterrupt
NonHandledInterrupt.l
	iret
	
isr_timer3
	MOV TIM3_CR1,#%00000000 ;disable timer during interrupt
	ldw y, counter
	cpw y, #4
	jreq is_max
	ld A, TIM2_CCR1H
	ld xh, A
	ld A, TIM2_CCR1L
	ld xl, A
	sllw x ;to double we shift left
	ld A, xh
	ld TIM2_CCR1H, A
	ld A, xl
	ld TIM2_CCR1L, A
	incw y
	ldw counter, y
	bres TIM3_SR1,#0
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
	dc.l {$82000000+isr_timer3}	; irq15
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
