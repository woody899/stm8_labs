stm8/

	#include "mapping.inc"
	#include "stm8s105k.inc"
	
	segment 'ram1'
index DS.W
flag DS.W  ;0 = forward, 1 = reverse
	
	segment 'rom'
array_length DC.W 8
values_arr DC.W $4E20,$1A0A,$0FA0,$08AE ;each value takes 2
main.l																	;memory addresses
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
	MOV TIM2_CR1,#%00000001 ; counter enable ON
	MOV TIM2_IER,#$00 ; no interrupts are required for PWM
	MOV TIM2_CCMR1,#%01100000 ; PWM mode 1 + CC1 as output
	MOV TIM2_CCER1,#%00000001 ; CC1 output enabled
	
	bset PE_CR2,#5
	
	rim
	
	
	ldw x,#0
	ldw index, x
	ldw flag, x
	
infinite_loop.l
	jra infinite_loop

arr_forward
	ldw x, index
	call setup_timer2
	incw x
	ldw index, x
	cpw x, array_length
	jreq change_direction_reverse
	iret
	
change_direction_reverse
	ldw x,#1
	ldw flag,x
	iret

change_direction_forward
	ldw x,#0
	ldw flag,x
	iret

arr_reverse
	ldw x, #4
	ldw index, x
	
reverse_loop
	ldw x, index
	call setup_timer2
	decw x
	decw x
	decw x
	ldw index,x
	cpw x, #0
	jreq change_direction_forward
	iret



setup_timer2
	;timer 2 setup
	
	ld A,(values_arr,x)
	ld yh, A
	ld TIM2_ARRH,A
	incw x
	ldw index, x
	ld A,(values_arr,x)
	ld yl,A
	ld TIM2_ARRL,A

	;setting the duty cycle 50% at all times
	srlw y
	ld A,yh
	ld TIM2_CCR1H,A
	ld A, yl
	ld TIM2_CCR1L,A
	ret


	interrupt NonHandledInterrupt
NonHandledInterrupt.l
	iret

isr_E
	ldw x,#0
	cpw x,flag
	jreq arr_forward
	ldw x, index
	cpw x,array_length ;if it has reached the last value
	jreq arr_reverse
	ldw x,#1
	cpw x,flag
	jreq reverse_loop
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
	dc.l {$82000000+isr_E}	; irq7
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
