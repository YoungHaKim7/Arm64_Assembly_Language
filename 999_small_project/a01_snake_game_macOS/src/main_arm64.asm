.equ speed1 , 0xF0000
.equ speed2 , 0x8F00
.equ speed3 , 0xFF0
.text
.global _main

_main:	mov x9,#3;  x9 will be used for the total no of elements in the list

	// Initialize terminal
	bl _init_term

	bl seed;
	adrp x3, init@PAGE
	add x3, x3, init@PAGEOFF
	mov x4,x3; WILL BE BOTTOM OF THE QUE
	mov x7,#0x5F;
	mov x11,#0xFF; // this is the size of the que

	// Call C function to clear screen instead of svc #0x206
	bl _clear_screen_custom

	mov x10,#240;
	str x10,[x3],#4;
	mov x10,#241;
	str x10,[x3],#4;
	mov x10,#242;
	str x10,[x3];

	// Initialize snake - skip printing for now
	mov x1,#8
	adrp x2, star@PAGE
	add x2, x2, star@PAGEOFF
	mov x0,#16;
	// Skip initial snake printing for debugging

	bl createbox;
	bl RANDOMPOINT;

start:	// Simple delay loop instead of checking for key
	mov x8,#10000;
delay_loop1:
	sub x8,x8,#1;
	cmp x8,#0;
	b.ne delay_loop1;
	// Simulate a key press to start the game
	mov x6,#'w';
	b CHK;

CHK: 	clz x5,x6;    cheking which key is pressed
	neg x5,x5;
	add x5,x5,#32;

	cmp x5,#2;
	beq TOP;

	cmp x5,#5;
	beq LEFT;

	cmp x5,#7;
	beq RIGHT;

	cmp x5,#10;
	beq BOT;

	b start;

TOP:	subs x11,x11,#1; if top key pressed then move snake ccordingly
	b.le COPYBACK;
	ldr x10,[x3];
	cmp x10,#32;
	blt GAMEOVER;
	sub x10,x10,#32;
	add x3,x3,#4;
	str x10,[x3];
	bl intersection;
	bl Delay;
	bl DELETE;
	bl PRINT;
	bl CHECKu;
	b TOP;

BOT:	subs x11,x11,#1;
	b.le COPYBACK;
	ldr x10,[x3];
	ldr x5,=385;
	cmp x10,x5;
	b.ge GAMEOVER;
	add x10,x10,#32;
	add x3,x3,#4;
	str x10,[x3];
	bl intersection;
	bl Delay;
	bl DELETE;
	bl PRINT;
	bl CHECKb;
	b BOT;

LEFT:	subs x11,x11,#1;
	b.le COPYBACK; circular ques
	ldr x10,[x3];
	lsl x8,x10,#27;
	cmp x8,#0;
	beq GAMEOVER;
	sub x10,x10,#1;
	add x3,x3,#4;
	str x10,[x3];
	bl intersection;
	bl Delay;
	bl DELETE;
	bl PRINT;
	bl CHECKl;
	b LEFT;

RIGHT:	subs x11,x11,#1;
	b.le COPYBACK;
	ldr x10,[x3];
	and x8,x10,#0X1F;
	cmp x8,#0X1F;
	beq GAMEOVER;
	add x10,x10,#1;
	add x3,x3,#4;
	str x10,[x3];
	bl intersection;
	bl Delay;
	bl DELETE;
	bl PRINT;
	bl CHECKr;
	b RIGHT;

DELETE:	str lr,[sp,#-16]!;  to delete the tail
	adrp x2, space@PAGE
	add x2, x2, space@PAGEOFF
	ldr x10,[x4];
	and x0,x10,#0X1F;
	lsr x1,x10,#5;
	add x1,x1,#1;
	svc #0X204;
	add x4,x4,#4;
	ldr lr,[sp],#16;

PRINT:	str lr,[sp,#-16]!; to add the head
	adrp x2, star@PAGE
	add x2, x2, star@PAGEOFF
	ldr x10,[x3];
	and x0,x10,#0X1F;
	lsr x1,x10,#5;
	add x1,x1,#1;
	svc #0X204;
	ldr lr,[sp],#16;

CHECKu:	str lr,[sp,#-16]!;  checking the codition for catch of food. if yes the add the head to top.
	ldr x10,[x3];
	cmp x10,x7;
	b.ne no_food_u;
	add x9,x9,#1;
	sub x10,x10,#32;
	add x3,x3,#4;
	str x10,[x3];
	bl PRINT;
	bl RANDOMPOINT;
no_food_u:
	mov x0,#0;
	svc #0x203;
	cmp x0,#0;
	csel x6,x0,x6,ne;
	b.ne CHK;
	ldr lr,[sp],#16;

CHECKb:	str lr,[sp,#-16]!;
	ldr x10,[x3];
	cmp x10,x7;
	b.ne no_food_b;
	add x9,x9,#1;
	add x10,x10,#32;
	add x3,x3,#4;
	str x10,[x3];
	bl PRINT;
	bl RANDOMPOINT;
no_food_b:
	mov x0,#0;
	svc #0x203;
	cmp x0,#0;
	csel x6,x0,x6,ne;
	b.ne CHK;
	ldr lr,[sp],#16;

CHECKl:	str lr,[sp,#-16]!;
	ldr x10,[x3];
	cmp x10,x7;
	b.ne no_food_l;
	add x9,x9,#1;
	sub x10,x10,#1;
	add x3,x3,#4;
	str x10,[x3];
	bl PRINT;
	bl RANDOMPOINT;
no_food_l:
	mov x0,#0;
	svc #0x203;
	cmp x0,#0;
	csel x6,x0,x6,ne;
	b.ne CHK;
	ldr lr,[sp],#16;

CHECKr:	str lr,[sp,#-16]!;
	ldr x10,[x3];
	cmp x10,x7;
	b.ne no_food_r;
	add x9,x9,#1;
	add x10,x10,#1;
	add x3,x3,#4;
	str x10,[x3];
	bl PRINT;
	bl RANDOMPOINT;
no_food_r:
	mov x0,#0;
	svc #0x203;
	cmp x0,#0;
	csel x6,x0,x6,ne;
	b.ne CHK;
	ldr lr,[sp],#16;



GAMEOVER:
	// Gameover conditions
	adrp x2, gameover@PAGE
	add x2, x2, gameover@PAGEOFF
	mov x0,#0;
	mov x1,#0;
	svc #0x204;
	mov x1,#1;
	adrp x2, Cscore@PAGE
	add x2, x2, Cscore@PAGEOFF
	svc #0x204;
	mov x2,x9; PRINTING THE VALUE OF SCORE
	mov x0,#15;
	svc #0x205;
	mov x0,#0;

	bl gethighscore;
	cmp x9,x3;
	b.le prints;
	b.gt storehighscore;
	mov x1,#2;
	adrp x2, congo@PAGE
	add x2, x2, congo@PAGEOFF
	mov x0,#0;
	svc #0X204;

	bl gethighscore;
prints:	mov x0,#0;
	mov x1,#3;
	adrp x2, Hscore@PAGE
	add x2, x2, Hscore@PAGEOFF
	svc #0x204;
	mov x2,x3;
	mov x0,#24;
	svc #0x205;


end:	// Restore terminal before exiting
	bl _restore_term
	// Call C exit function instead of direct system call
	bl _exit

RANDOMPOINT:
	// Random point Generation
	str x5,[sp,#-16]!;
	str lr,[sp,#-16]!;
	bl seed;
	adrp x7, rand@PAGE
	add x7, x7, rand@PAGEOFF
	ldr x7,[x7];
	ldr x5,=0x1FF;
	and x7,x7,x5;
	ldr x5,=404;
	cmp x7,x5;
	b.ge skip_sub;
	sub x7,x7,#0xff;
skip_sub:
	bl intersectionfood;
	adrp x2, food@PAGE
	add x2, x2, food@PAGEOFF
	and x0,x7,#0X1F;
	lsr x1,x7,#5;
	add x1,x1,#1;
	svc #0X204;
	ldr lr,[sp],#16;
	ldr x5,[sp],#16;


COPYBACK:str lr,[sp,#-16]!;
	mov x5,x9; TEMPORAY CHANGED TO x5 HAVE TO CHANGE TO x9
	adrp x8, init@PAGE
	add x8, x8, init@PAGEOFF
loopi:	ldr x6,[x4] ; back of the que goes to beginning
	str x6,[x8];
	add x8,x8,#4;
	add x4,x4,#4;
	sub x5,x5,#1;
	cmp x5,#0;
	b.ne loopi;
	sub x3,x8,#4;

	adrp x4, init@PAGE
	add x4, x4, init@PAGEOFF
	mov x11,#0xFF;
	ldr lr,[sp],#16;

Delay:	str lr,[sp,#-16]!;
	cmp x9,#10
	b.le speed1_branch;
	cmp x9,#20;
	b.le speed2_branch;
	mov x6,#speed3;
	b speed_loop;
speed1_branch:
	mov x6,#speed1;
	b speed_loop;
speed2_branch:
	mov x6,#speed2;
speed_loop:
	cmp x6,#0;
	b.ne speed_sub;
	ldr lr,[sp],#16;
	b delay_done;
speed_sub:
	sub x6,x6,#1;
	b speed_loop;
delay_done:

createbox:
	str lr,[sp,#-16]!;
	mov x0,#0;
	mov x6,#32;
	adrp x2, dash@PAGE
	add x2, x2, dash@PAGEOFF
loopk:	mov x1,#0;
	svc #0X204;
	mov x1,#14;
	svc #0X204;
	sub x6,x6,#1;
	add x0,x0,#1;
	cmp x6,#0;
	b.ne loopk;

	// this part of the code is fo printing horizontal pipes
	mov x1,#1;
	mov x0,#32;
	mov x6,#32;

	adrp x2, pipe@PAGE
	add x2, x2, pipe@PAGEOFF
loopl:	svc #0X204;
	sub x6,x6,#1;
	add x1,x1,#1;
	cmp x6,#0;
	b.ne loopl;

	ldr lr,[sp],#16;


seed:	str lr,[sp,#-16]!;     Making the food to appear in different places.
	adrp x6, rand@PAGE
	add x6, x6, rand@PAGEOFF
	// For now, use a simple counter instead of time
	// svc #0x6d; taking the ccurrent time (Linux syscall)
	ldr x0,[x6]
	add x0, x0, #1  // Simple increment instead of time
	str x0,[x6]
	ldr lr,[sp],#16;


intersection:
	// checking wheter snake intersects itself?
	str lr,[sp,#-16]!;
	mov x5,x9;
	ldr x10,[x3];
	mov x12,x4;

loopm:	ldr x6,[x12],#4;
	cmp x6,x10;
	b.eq GAMEOVER;
	sub x5,x5,#1;
	cmp x5,#0;
	b.ne loopm;
	ldr lr,[sp],#16;

intersectionfood:
	// checking whether food generated is intersecting with snake?
	str lr,[sp,#-16]!;
	mov x5,x9;
	ldr x10,[x3];
	mov x12,x4;

loopn:	ldr x6,[x12],#4;
	cmp x6,x7;
	b.eq seed;   if it intersects then generate a new value for seed and check again...
	bl RANDOMPOINT;
	sub x5,x5,#1;
	cmp x5,#0;
	b.ne loopn;
	ldr lr,[sp],#16;




storehighscore:
	// Skip file operations for now to avoid macOS compatibility issues
	str lr,[sp,#-16]!;
	mov x3,x9;  // Just store the score in x3
	ldr lr,[sp],#16;


gethighscore:
	// Skip file operations for now to avoid macOS compatibility issues
	str lr,[sp,#-16]!;
	mov x3,#0;  // Default highscore to 0
	ldr lr,[sp],#16;


	.data
OutFileHandle: .word 0
InFileHandle: .word 0
chararray: .skip 80;
gameover: .asciz "The game is Over my boy !!!"
Cscore:	.asciz "Your score is "
Hscore:	.asciz "Highest score ever is "
congo: 	.asciz "You got a highscore Congrats :-)"


space: 	.asciz " "
star:	.asciz "*"
food:	.asciz "#"
dash:	.asciz "-"
pipe:	.asciz "|"
rand:	.word  80;

highscore: .asciz "HighScore.sha" ;
init: 	.word 0



	.end

// we will be usin x0 aka x5 for cols
// we will be usin x1 aka x6 for rows
// will use x8 to change the location of the pointer everytime