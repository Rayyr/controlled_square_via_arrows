#bitmap Display config
#unit width=32 px
#unit height=32 px
#width=512 px
#height =512px
#we have 16 unit in each row ( 512/32)
#base address for displaying : 0x10008000
#since each unit(square) size =32px then its size=4Bytes
#todo : arrow-controlled square in 4 directions , when it reaches 
#the bottom-right corner and hit right arrow then it will be wrapped 
#to the top-left corner ( from start ) , the same if the square in 
#1sr row and hit up arrow then it will be wrapped to the last row 
# the same with the similar cases 


.macro bi
li $v0,10
syscall
.end_macro

 


.data
start:  .word 0x10008000 #first cell in the 1st row
last:   .word 0x100083FC #last cell unit in last row  
first_unit_in_last_row: .word 0x100083ED #last-15squares
last_unit_in_first_row: .word 0x1000800f #start+15squares

red:.word 0x00ff0000
black : .word 0x00000000
 

.text


main:
 
square_drawer:#its length=1 square
lw $t1,start
lw $t0,red
sw  $t0,0($t1)
addi $t8,$t1,0#current unit
  
  
check_keyboard:
 
lw  $t2, 0xFFFF0000                  # check keyboard status
beq $t2, $zero, check_keyboard       # if 0, no key pressed, wait actually untill key is pressed ( loop ) 
lw  $t3, 0xFFFF0004                  # read the key value from receiver data buffer 
beq $t3,'d', move_right              # if 'd' pressed, go move right
beq $t3,'a',move_left                # if 'a' pressed, go move left
beq $t3,'w',move_up
beq $t3,'s',move_down
beq $t3,'c',exit              

j check_keyboard



move_right:
#check if the current unit is the last unit 
andi $t6,$t6,0#clr $t6
andi $t4,$t4,0#clr $t4
addi $t6,$t6,4
addi $t4,$t4,255 
multu $t4,$t6#res=Lo reg
mflo $t4#t4=t4*t6
addi $t4,$t4,0x10008000#t4=255+(start)
#all previous calculations can be replaced with lw$t2,last
beq $t8,$t4,to_first_unit#16*16=256 unit so the last unit address = 256(start_unit_address) 

#here i follow this order : draw then clear unit
addi $t9,$t8,0#current unit address
lw $t0,red
sw $t0,4($t9)#draw  

lw $t5,black
sw $t5,0($t8)#clear 
 
addi $t8,$t8,4#update t8 to current unit
j check_keyboard



move_left:
#check if the current unit is teh first unit
lw $t2,start 
beq $t8,$t2,to_last_unit

#here i follow this order : draw then clear unit
addi $t9,$t8,0
lw $t0,red
sw $t0,-4($t9)#draw new unit , -:means backward address

lw $t5,black
sw $t5,0($t8)#clear 

addi $t8,$t8,-4#update t8 to current unit
j check_keyboard
 


move_up:
#check if the current unit in first row 
lw $t2,last_unit_in_first_row
bleu $t8,$t2,to_corrosponding_unit_last_row
#here i follow this order : draw then clear unit
addi $t9,$t8,0
lw $t0,red
sw $t0,-64($t9)#draw , -4*16Bytes

lw $t5,black
sw $t5,0($t8)#clear

addi $t8,$t8,-64#update t8 to current unit
j check_keyboard



move_down:
#check if nxt unit is outside the bitmap display
lw $t1,first_unit_in_last_row
bgeu $t8,$t1,to_corrosponding_unit_first_row
 
#here i follow this order : draw then clear unit
addi $t9,$t8,0
lw $t0,red
sw $t0,64($t9)#draw , 4*16Bytes

lw $t5,black
sw $t5,0($t8)#clear

addi $t8,$t8,64#update t8 to current unit
j check_keyboard

exit:
bi




to_first_unit:
lw $t1,start
lw $t2,black
lw $t3,last
sw $t2,0($t3)#clear the last unit in last row
#as same as sw $t2,0($t8)

lw $t2,red
sw $t2,0($t1)#draw 1st unit in 1st row

addi $t8,$t1,0#update t8 is 1st unit 
j check_keyboard




to_last_unit:
lw $t1,start
lw $t2,black
sw $t2,0($t1)#clear the first unit in last row
#as same as sw $t2,0($t8)

lw $t2,red
lw $t1,last
sw $t2,0($t1)#draw to the last unit

addi $t8,$t1,0#update t8 is last unit
j check_keyboard



to_corrosponding_unit_first_row:
 
lw $t2,black
sw $t2,0($t8)#clear the current unit

lw $t2,red
sw $t2,-1024($t8)#draw to corrosponding unit in first row

addi $t8,$t8,-1024#16*16*4Bytes update t8 
j check_keyboard





to_corrosponding_unit_last_row:
 
lw $t2,black
sw $t2,0($t8)#clear the current unit

lw $t2,red
sw $t2,1024($t8)#draw to corrosponding unit in last row

addi $t8,$t8,1024#16*16*4Bytes update t8 
j check_keyboard