stm8/

	#include "mapping.inc"
	#include "stm8s105k.inc"
value EQU 128
	
	segment 'ram1'
array1 DS.B 16
pattern DS.B
obtained DS.W
index DS.W
	
	segment 'rom'
pitch DC.W 2273,2024,1910,1702,1516,1432,1276,1136 
kr_patterns DC.B 3,6,12,24,48,96,192
array_length DC.W 16
lower_limit DC.W 0
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
	MOV TIM2_CR1,#%00000000 ; counter enable ON
	MOV TIM2_IER,#$00 ; no interrupts
  MOV TIM2_CCMR1,#%01100000 ; PWM mode 1 + CC1 as output
	MOV TIM2_CCER1,#%00000001 ; enable cc1 output
;	MOV TIM2_ARRH, #$00
;	MOV TIM2_ARRL,#$64
;	MOV TIM2_CCR1H,#$00					;duty cycle 10% means 10% of ARR value, so on so forth
;	MOV TIM2_CCR1L,#$64
	
;	mov PD_DDR, #$ff
;	mov PD_CR1, #$ff

; for us to make the value access the array every 0.5s
; we use timer 3, and inside the interrupt of tim3
; we can run the code that does that. ( for exercise 4)
	MOV TIM3_CR1,#%00000000 ; TIM3 OFF
	MOV TIM3_PSCR,#$07 ; prescaler x128
	BSET TIM3_EGR,#0 ; force UEV to update prescaler
	MOV TIM3_IER,#$01 ; TIM3 interrupt on update enabled
	MOV TIM3_ARRH, #$1E	;500 ms delay
	MOV TIM3_ARRL, #$85
	
	
;*****Exercise 3*****;	
;	ldw x,#0
;	ld A,#1
	
;fill_array
;	ld (array1,x),A
;	sll A
;	incw x
;	cp A,value
;	jreq infinite_loop
;	jra fill_array 
;NOTE ON THIS EXERCISE
; YOU MIGHT WANT TO PUT THE LOADING AFTER THE COMPARISON
;*********************;

;****Exercise 4*******;
;	ldw x,#0
	
	
;read_array
;	ld A,(kr_patterns,x)
;	ld pattern,A
;	wfi 
;	MOV TIM3_CR1,#%00000001
;	cpw x,array_length
;	jreq reverse
;	incw x
;	jra read_array

;reverse
;	decw x
;	ld A,(kr_patterns,x)
;	ld pattern, A
;	wfi
;	MOV TIM3_CR1,#%00000001
;	cpw x,#0
;	jreq read_array
;	jra reverse
;**********************;

;*****Exercise 5*******;

;	ld A,#0
	rim

	ldw x, #0

infinite_loop.l
	
	cpw x,#0
	jreq play_sound_forward
	cpw x,array_length		;if it has reached last tune
	jreq reverse_mode	; we play in reverse
	jra infinite_loop
	
	
play_sound_forward
	call setup_timer2
	MOV TIM2_CR1,#%00000001 ; turn on buzzer
	MOV TIM3_CR1,#%00000001 ; turn on timer
	wfi
	incw x
	cpw x, array_length ;check if it has reached the last tune
	jreq infinite_loop
	jra play_sound_forward

reverse_mode
	ldw x, #12
	ldw index, x
	
loop_reverse
	ldw x, index

play_sound_reverse
	call setup_timer2
	MOV TIM2_CR1,#%00000001 ; turn on buzzer
	MOV TIM3_CR1,#%00000001 ; turn on timer
	wfi
	decw x
	decw x
	decw x
	ldw index, x
	ldw y, index
	cpw y, lower_limit
	jreq end_sound
	jra loop_reverse


end_sound
	ret
	

setup_timer2
	ld A,(pitch,x)
	ld yh, A
	ld TIM2_ARRH, A
	incw x
	ld yl, A
	ld A,(pitch,x)
	ld TIM2_ARRL,A
	
	;Setting the duty cycle
	srlw y
	ld A, yh
	ld TIM2_CCR1H, A
	ld A, yl
	ld TIM2_CCR1L, A
	ret
	

	interrupt NonHandledInterrupt
NonHandledInterrupt.l
	iret

timer_change
	MOV TIM3_CR1,#%00000000 ;turn off timer
	MOV TIM2_CR1,#%00000000 ;turn off buzzer
;	mov PD_ODR,pattern for exercise 5
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
	dc.l {$82000000+timer_change}	; irq15
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
