.syntax unified
.global main

.type main, %function
main:
  @ initialisation
  bl init

  @init for bigger frequency triangle wave
  ldr r5, =#48000 @sample rate
  ldr r6, =#440 @desired frequency
  udiv r7, r5, r6 @number of outputs needed for frequency per period
  mov r9, #2
  udiv r7, r7, r9 @ number of outputs needed for frequency per half period
  ldr r4, =0x4000 @top of range
  ldr r6, =-0x4000 @bottom of range
  mul r8, r4, r9 @full range of numbers
  udiv r8, r8, r7 @number to increase/decrease by
  mov r6, 0 @big triangle state - 0 is decreasing, 1 is increasing

  @init for smaller frequency sawtooth wave
  ldr r5, =#48000 @sample rate
  ldr r6, =#220 @desired frequency
  udiv r7, r5, r6 @number of outputs needed for frequency per period
  mov r9, #2
  ldr r5, =0x3000 @top of range
  ldr r6, =-0x3000 @bottom of range
  mul r10, r5, r9 @full range of numbers
  udiv r10, r10, r7 @number to increase/decrease by

  @r4 - big tri counter
  @r5 - small tri counter
  @r8 - big tri scaler
  @r10 - small tri scaler

  b bigstate

@subtracts from triangle counter until lower limit is reached
bigsubloop:
  @adds the counters together to create the additive wave sound
  add r0, r4, r5
  bl BSP_AUDIO_OUT_Play_Sample

  @sets the state for the big triangle - now decreasing
  mov r6, 0

  @ calculate the next value in the triangle signal
  subs r4, r8

  @checks if the counter is less than or equal to the lower limit, 
  @if it is, go to the adding state
  cmp r4, -0x4000
  ble bigaddloop
  beq bigaddloop

  b smallsubloop

@adds to triangle counter until upper limit is reached
bigaddloop:
  @adds the counters together to create the additive wave sound 
  add r0, r4, r5
  bl BSP_AUDIO_OUT_Play_Sample

  mov r6, 1

  @ calculate the next value in the triangle signal
  adds r4, r8

  @checks if the counter is greater than or equal to the upper limit,
  @if it is, go to the subtracting state
  cmp r4, 0x4000
  bgt bigsubloop
  beq bigsubloop

  b smallsubloop

@subtracts from sawtooth counter until lower limit is reached
smallsubloop:
  @ calculate the next value in the triangle signal
  subs r5, r10

  @checks if the counter is less than or equal to the lower limit
  cmp r5, -0x3000
  ble smalladdloop
  beq smalladdloop

  b bigstate

@resets sawtooth counter to upper limit
smalladdloop:
  ldr r5, =0x3000
  b smallsubloop

@goes to either big subloop or big addloop depending on the state set in r6
bigstate:
  cmp r6, 0
  beq bigsubloop
  b bigaddloop
