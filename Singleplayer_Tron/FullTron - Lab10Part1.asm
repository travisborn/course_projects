INCLUDE Irvine32.inc

.data
tronTitle BYTE "TRON",0
controlMenu BYTE ">>>>>CONTROLS<<<<<",0
spc BYTE         "SPACEBAR  : start/pause",0
escp BYTE        "ESCAPE KEY: quit game",0
arro BYTE        "ARROW KEYS: control light-bike",0
pushSpace BYTE   "push SPACE to start TRON",0
restart BYTE     "press ENTER to restart TRON or press ESCAPE to quit TRON",0
scoreStr BYTE    "SCORE : ",0
levelStr BYTE    "LEVEL : ",0
totalStr BYTE    "TOTAL : ",0
bikeVert BYTE 124 ;complex bike and trail pieces to next comment
bikeHorz BYTE 196
bikeLeftDown BYTE 191
bikeRightUp BYTE 192
bikeLeftUp BYTE 217
bikeRightDown BYTE 218
trailVert BYTE 186
trailHorz BYTE 205
trailLeftDown BYTE 187
trailLeftUp BYTE 188
trailRightUp BYTE 200
trailRightDown BYTE 201 ;down to here is the complex bike and trail stuff

wallTop BYTE 220   ;top half block
wallBot BYTE 223   ;bottom half block
wallBlock BYTE 219 ;regular full block
crash BYTE 177     ;distorted full block
space BYTE 32

leftDL BYTE 74
rightDL BYTE 75
leftDH BYTE 0
rightDH BYTE 0

bikeDL BYTE 88
bikeDH BYTE 31
delayBike BYTE 100
delayBackground BYTE 10
delayReadKey BYTE 50

crashEnd BYTE 0
rows BYTE 60
cols BYTE 146
totalScore DWORD 0
score DWORD 0
scoreCheck DWORD 0

board BYTE 8760 DUP(0);2D array representation of the board, 146X60 = 8760 tiles. 

;random rectangle stuff
;box char's
nextLevel BYTE 0
topLeft BYTE 201
horiz BYTE 205
topRight BYTE 187
side BYTE 186
spaceRect BYTE 255
botLeft BYTE 200
botRight BYTE 188

;coordinate stuff
borderSide BYTE 147
borderBot BYTE 60
sideScreen BYTE 0
botScreen BYTE 0

ranX BYTE 0
ranY BYTE 0

.code
main PROC
	call Randomize ;seed for randomrange
	call showTRON
playGame:
	call drawBorder
	
	push edx
	push eax
	mov dl,18
	mov dh,64
	call gotoxy
	mov eax, white+(black*16)
	call SetTextColor
	movzx eax,nextLevel
	call writeDec
	mov eax, cyan+(black*16)
	call SetTextColor
	pop eax
	pop edx
	
	cmp nextLevel,0
	je aroundObstacle
	call createObstacle
	call startZone
	
aroundObstacle:
	call controls
	call startGame
call changeBoard
	call lightBike
	cmp ah,001h
	je endGame
	
	mov dl,50
	mov dh,62
	call gotoxy
	mov eax, cyan+(black*16)
	call SetTextColor
	mov edx,OFFSET restart
	call writeString
	
redo:
	movzx eax,delayReadKey
	call delay
	call readKey
	jz redo
	
	cmp ah,01Ch
	jne aroundEnter
	mov bikeDL,88
	mov bikeDH,31
	mov leftDL,74
	mov rightDL,75
	mov leftDH,0
	mov rightDH,0
	mov dl,50
	mov dh,62
	call gotoxy
	movzx eax,space
	mov ecx,60
erase:
	call writeChar
loop erase

	cmp score,20 ;make larger after testing
	jl aroundNextLevel
	add nextLevel,1
aroundNextLevel:
	call resetBoard
	jmp playgame
aroundEnter:
	
	cmp ah,001h
	jne redo
endGame:
	mov eax, white+(black*16)
	call SetTextColor
	call Clrscr
exit

main ENDP


changeBoard PROC
	pushad
	
	mov esi,OFFSET board ;setup registers for 2d array math
	movzx eax,bikeDH ;# of rows is 60
	mov ebx,146      ;# of columns is 146 (2 to 147)
	
	mul ebx ;multiplys al, which has the row the bike is in, with bl, which has the number of columns
	movzx ebx,bikeDL
	add esi,eax
	add esi,ebx ;esi will have board OFFSET + (currentRow * #columns) + currentColumn
	
	cmp BYTE ptr [esi],1
	jne noCrash
	movzx eax,crash
	call writeChar
	mov crashEnd,1
	jmp crashed
noCrash:
	call changeScore
	;add score,100 ;test end condition
	mov BYTE ptr [esi],1
crashed:	
	popad
RET
changeBoard ENDP


resetBoard PROC
	pushad
	
	mov eax,0
	
	cmp score,20
	jge continue
	mov totalScore,0
	mov dl,18
	mov dh,65
	call gotoxy
	mov ecx,4
	movzx eax,space
eraseTotal:
	call writeChar
loop eraseTotal
	mov nextLevel,0
continue:
	
	mov crashEnd,0
	mov score,0
	mov scoreCheck,0
	mov delayBike,100 ;make 1000 for actual game, 100 just to test
	mov dl,18
	mov dh,66
	call gotoxy
	mov ecx,4
	movzx eax,space
eraseScore:
	call writeChar
loop eraseScore
	
	mov esi,OFFSET board

	mov ecx,lengthof board
reset:
	mov BYTE ptr [esi],0
	;movzx eax, byte ptr [esi]
	;call writedec
	;call crlf
	inc esi
loop reset

	popad
RET
resetBoard ENDP


changeScore PROC
	pushad
	
	mov eax, white+(black*16)
	call SetTextColor
	
	mov dl,18
	mov dh,65
	call gotoxy
	mov eax,totalScore
	call writeDec
	
	mov dl,18
	mov dh,66
	call gotoxy
	mov eax,score
	call writeDec
	
	cmp scoreCheck,100 ;make 1000 for actual game, 100 just to test
	jne cont
	mov scoreCheck,0
	cmp delayBike,10
	je cont
	sub delayBike,10
	
cont:
	inc score
	inc totalScore
	inc scoreCheck
	
	mov eax, lightmagenta+(lightgray*16)
	call SetTextColor
	
	mov dl,bikeDL
	mov dh,bikeDH
	call gotoxy

	popad
RET
changeScore ENDP


lightBike PROC
	;jmp moveLeft ;randomize starting direction here
	mov eax,4
	call randomRange ;0-3
	
	cmp eax,0
	jne notLeft
	jmp moveLeft
notLeft:
	
	cmp eax,1
	jne notRight
	jmp moveRight
notRight:

	cmp eax,2
	jne notUp
	jmp moveUp
notUp:
	jmp moveDown
	
turnUpLeft:
	mov dl,bikeDL
	mov dh,bikeDH
	call gotoxy
	movzx eax,trailVert ;draw the trail where the bike was
	call writeChar
quickUpLeft:
	dec bikeDH
	mov dh,bikeDH
	cmp dh,0 ;check if crash top wall
	jne noUpLeftCrash
	movzx eax,crash
	call gotoxy
	call writeChar
jmp done
	
noUpLeftCrash:
	call gotoxy
	movzx eax,bikeLeftDown ;draw the up-left turn bike
	call writeChar
call changeBoard
cmp score,lengthof board
jge done
cmp crashEnd,1
je done
	
	movzx eax,delayBike
	call delay
	
	call gotoxy
	movzx eax,trailLeftDown ;draw the up-left trail
	call writeChar
	
	call readKey
	jz contTurnLeft1
	
	mov dh,bikeDH
	mov dl,bikeDL
	
	cmp ah,001h ;escape pressed, quit game
	jne contLeftEscape1
jmp done
contLeftEscape1:
	
	cmp ah,039h ;spacebar pressed, pause game
	jne contLeftPause1
	call pauseGame
contLeftPause1:
	
	cmp ah,048h ;up arrow pressed, turn up
	jne contLeftUp1
	mov dh,bikeDH
	jmp quickLeftUp
contLeftUp1:
	
	cmp ah,050h ;down arrow pressed, turn down
	jne contLeftDown1
	mov dh,bikeDH
	jmp quickLeftDown
contLeftDown1:
contTurnLeft1:
	mov dh,bikeDH
	mov dl,bikeDL
	jmp afterTurnLeft

turnDownLeft:
	mov dl,bikeDL
	mov dh,bikeDH
	call gotoxy
	movzx eax,trailVert ;draw the trail where the bike was
	call writeChar
quickDownLeft:
	inc bikeDH
	mov dh,bikeDH
	cmp dh,61 ;check if crash bottom wall
	jne noDownLeftCrash
	movzx eax,crash
	call gotoxy
	call writeChar
jmp done
	
noDownLeftCrash:	
	call gotoxy
	movzx eax,bikeLeftUp ;draw the down-left turn bike
	call writeChar
call changeBoard
cmp score,lengthof board
jge done
cmp crashEnd,1
je done
	
	movzx eax,delayBike
	call delay
	
	call gotoxy
	movzx eax,trailLeftUp ;draw the down-left trail
	call writeChar
	
	call readKey
	jz contTurnLeft2
	
	mov dh,bikeDH
	mov dl,bikeDL
	
	cmp ah,001h ;escape pressed, quit game
	jne contLeftEscape2
jmp done
contLeftEscape2:
	
	cmp ah,039h ;spacebar pressed, pause game
	jne contLeftPause2
	call pauseGame
contLeftPause2:
	
	cmp ah,048h ;up arrow pressed, turn up
	jne contLeftUp2
	mov dh,bikeDH
	jmp quickLeftUp
contLeftUp2:

	cmp ah,050h ;down arrow pressed, turn down
	jne contLeftDown2
	mov dh,bikeDH
	jmp quickLeftDown
contLeftDown2:
contTurnLeft2:
	mov dh,bikeDH
	mov dl,bikeDL
	jmp afterTurnLeft
	
moveLeft: ;moves the bike left one space
	mov dl,bikeDL
	mov dh,bikeDH
	call gotoxy
	movzx eax,trailHorz ;draw the trail where the bike was
	call writeChar
	
afterTurnLeft:
	dec bikeDL
	mov dl,bikeDL
	call gotoxy
	movzx eax,bikeHorz ;draw bike at new location
	call writeChar
	call gotoxy
call changeBoard
cmp score,lengthof board
jge done
cmp crashEnd,1
je done
	
	cmp dl,1 ;check if crash left wall
	jne noLeftCrash
	movzx eax,crash
	call writeChar
	dec dl
	call gotoxy
	call writeChar
jmp done
	
noLeftCrash:	
	movzx eax,delayBike
	call delay
	call readKey
	jz noKeyLeft
	
	cmp ah,001h ;escape pressed, quit game
	jne aroundLeftEscape
jmp done
aroundLeftEscape:
	
	cmp ah,039h ;spacebar pressed, pause game
	jne aroundLeftPause
	call pauseGame
aroundLeftPause:
	
	cmp ah,048h ;up arrow pressed, turn up
	jne aroundLeftUp
	jmp turnLeftUp
aroundLeftUp:
	
	cmp ah,050h ;down arrow pressed, turn down
	jne aroundLeftDown
	jmp turnLeftDown
aroundLeftDown:
noKeyLeft:
	jmp moveLeft

turnUpRight:
	mov dl,bikeDL
	mov dh,bikeDH
	call gotoxy
	movzx eax,trailVert ;draw the trail where the bike was
	call writeChar
quickUpRight:
	dec bikeDH
	mov dh,bikeDH
	cmp dh,0 ;check if crash top wall
	jne noUpRightCrash
	movzx eax,crash
	call gotoxy
	call writeChar
jmp done
	
noUpRightCrash:
	call gotoxy
	movzx eax,bikeRightDown ;draw the down-left turn bike
	call writeChar
call changeBoard
cmp score,lengthof board
jge done
cmp crashEnd,1
je done
	
	movzx eax,delayBike
	call delay
	
	call gotoxy
	movzx eax,trailRightDown ;draw the down-left trail
	call writeChar
	
	call readKey
	jz contTurnRight1
	
	mov dh,bikeDH
	mov dl,bikeDL
	
	cmp ah,001h ;escape pressed, quit game
	jne contRightEscape1
jmp done
contRightEscape1:
	
	cmp ah,039h ;spacebar pressed, pause game
	jne contRightPause1
	call pauseGame
contRightPause1:
	
	cmp ah,048h ;up arrow pressed, turn up
	jne contRightUp1
	mov dh,bikeDH
	jmp quickRightUp
contRightUp1:
	
	cmp ah,050h ;down arrow pressed, turn down
	jne contRightDown1
	mov dh,bikeDH
	jmp quickRightDown
contRightDown1:
contTurnRight1:
	mov dh,bikeDH
	mov dl,bikeDL

	jmp afterTurnRight
	
turnDownRight:
	mov dl,bikeDL
	mov dh,bikeDH
	call gotoxy
	movzx eax,trailVert ;draw the trail where the bike was
	call writeChar
quickDownRight:
	inc bikeDH
	mov dh,bikeDH
	cmp dh,61 ;check if crash bottom wall
	jne noDownRightCrash
	movzx eax,crash
	call gotoxy
	call writeChar
jmp done
	
noDownRightCrash:
	call gotoxy
	movzx eax,bikeRightUp ;draw the down-left turn bike
	call writeChar
call changeBoard
cmp score,lengthof board
jge done
cmp crashEnd,1
je done
	
	movzx eax,delayBike
	call delay
	
	call gotoxy
	movzx eax,trailRightUp ;draw the down-left trail
	call writeChar
	
	call readKey
	jz contTurnRight2
	
	mov dh,bikeDH
	mov dl,bikeDL
	
	cmp ah,001h ;escape pressed, quit game
	jne contRightEscape2
jmp done
contRightEscape2:
	
	cmp ah,039h ;spacebar pressed, pause game
	jne contRightPause2
	call pauseGame
contRightPause2:
	
	cmp ah,048h ;up arrow pressed, turn up
	jne contRightUp2
	mov dh,bikeDH
	jmp quickRightUp
contRightUp2:
	
	cmp ah,050h ;down arrow pressed, turn down
	jne contRightDown2
	mov dh,bikeDH
	jmp quickRightDown
contRightDown2:
contTurnRight2:
	mov dh,bikeDH
	mov dl,bikeDL

	jmp afterTurnRight
	
moveRight: ;moves the bike right one space
	mov dl,bikeDL
	mov dh,bikeDH
	call gotoxy
	movzx eax,trailHorz ;draw the trail where the bike was
	call writeChar
	
afterTurnRight:
	inc bikeDL
	mov dl,bikeDL
	call gotoxy
	movzx eax,bikeHorz ;draw bike at new location
	call writeChar
	call gotoxy
call changeBoard
cmp score,lengthof board
jge done
cmp crashEnd,1
je done
	
	cmp dl,148 ;check if crash right wall
	jne noRightCrash
	movzx eax,crash
	call gotoxy
	call writeChar
	call writeChar
jmp done
	
noRightCrash:
	movzx eax,delayBike
	call delay
	call readKey
	jz noKeyRight
	
	cmp ah,001h ;escape pressed, quit game
	jne aroundRightEscape
jmp done
aroundRightEscape:
	
	cmp ah,039h ;spacebar pressed, pause game
	jne aroundRightPause
	call pauseGame
aroundRightPause:
	
	cmp ah,048h ;up arrow pressed, turn up
	jne aroundRightUp
	jmp turnRightUp
aroundRightUp:
	
	cmp ah,050h ;down arrow pressed, turn down
	jne aroundRightDown
	jmp turnRightDown
aroundRightDown:
noKeyRight:
	jmp moveRight
	
turnRightUp:
	mov dl,bikeDL
	mov dh,bikeDH
	call gotoxy
	movzx eax,trailHorz ;draw the trail where the bike was
	call writeChar
quickRightUp:
	inc bikeDL
	mov dl,bikeDL
	cmp dl,148 ;check if crash right wall
	jne noRightUpCrash
	movzx eax,crash
	call gotoxy
	call writeChar
	call writeChar
jmp done
	
noRightUpCrash:
	call gotoxy
	movzx eax,bikeLeftUp ;draw the right-up turn bike
	call writeChar
call changeBoard
cmp score,lengthof board
jge done
cmp crashEnd,1
je done
	
	movzx eax,delayBike
	call delay
	
	call gotoxy
	movzx eax,trailLeftUp ;draw the right-up trail
	call writeChar
	
	call readKey
	jz contTurnUp1
	
	mov dh,bikeDH
	mov dl,bikeDL
	
	cmp ah,001h ;escape pressed, quit game
	jne contUpEscape1
jmp done
contUpEscape1:
	
	cmp ah,039h ;spacebar pressed, pause game
	jne contUpPause1
	call pauseGame
contUpPause1:

	cmp ah,04Dh ;right arrow pressed, turn right
	jne contUpRight1
	mov dl,bikeDL
	jmp quickUpRight
contUpRight1:
	
	cmp ah,04Bh ;left arrow pressed, turn left
	jne contUpLeft1
	mov dl,bikeDL
	jmp quickUpLeft
contUpLeft1:
contTurnUp1:
	mov dh,bikeDH
	mov dl,bikeDL

	jmp afterTurnUp
	
turnLeftUp:
	mov dl,bikeDL
	mov dh,bikeDH
	call gotoxy
	movzx eax,trailHorz ;draw the trail where the bike was
	call writeChar
quickLeftUp:
	dec bikeDL
	mov dl,bikeDL
	cmp dl,1 ;check if crash left wall
	jne noLeftUpCrash
	movzx eax,crash
	call gotoxy
	call writeChar
	dec dl
	call gotoxy
	call writeChar
jmp done
	
noLeftUpCrash:
	call gotoxy
	movzx eax,bikeRightUp ;draw the left-up turn bike
	call writeChar
call changeBoard
cmp score,lengthof board
jge done
cmp crashEnd,1
je done
	
	movzx eax,delayBike
	call delay
	
	call gotoxy
	movzx eax,trailRightUp ;draw the left-up trail
	call writeChar
	
	call readKey
	jz contTurnUp2
	
	mov dh,bikeDH
	mov dl,bikeDL
	
	cmp ah,001h ;escape pressed, quit game
	jne contUpEscape2
jmp done
contUpEscape2:
	
	cmp ah,039h ;spacebar pressed, pause game
	jne contUpPause2
	call pauseGame
contUpPause2:

	cmp ah,04Dh ;right arrow pressed, turn right
	jne contUpRight2
	mov dl,bikeDL
	jmp quickUpRight
contUpRight2:
	
	cmp ah,04Bh ;left arrow pressed, turn left
	jne contUpLeft2
	mov dl,bikeDL
	jmp quickUpLeft
contUpLeft2:
contTurnUp2:
	mov dh,bikeDH
	mov dl,bikeDL

	jmp afterTurnUp
	
moveUp: ;moves the bike up one space
	mov dl,bikeDL
	mov dh,bikeDH
	call gotoxy
	movzx eax,trailVert ;draw the trail where the bike was
	call writeChar
	
afterTurnUp:
	dec bikeDH
	mov dh,bikeDH
	call gotoxy
	movzx eax,bikeVert ;draw bike at new location
	call writeChar
	call gotoxy
call changeBoard
cmp score,lengthof board
jge done
cmp crashEnd,1
je done
	
	cmp dh,0 ;check if crash top wall
	jne noUpCrash
	movzx eax,crash
	call writeChar
jmp done
	
noUpCrash:
	movzx eax,delayBike
	add eax,10
	call delay
	call readKey
	jz noKeyUp
	
	cmp ah,001h ;escape pressed, quit game
	jne aroundUpEscape
jmp done
aroundUpEscape:
	
	cmp ah,039h ;spacebar pressed, pause game
	jne aroundUpPause
	call pauseGame
aroundUpPause:
	
	cmp ah,04Dh ;right arrow pressed, turn right
	jne aroundUpRight
	jmp turnUpRight
aroundUpRight:
	
	cmp ah,04Bh ;left arrow pressed, turn left
	jne aroundUpLeft
	jmp turnUpLeft
aroundUpLeft:
noKeyUp:
	jmp moveUp
	
turnRightDown:
	mov dl,bikeDL
	mov dh,bikeDH
	call gotoxy
	movzx eax,trailHorz ;draw the trail where the bike was
	call writeChar
quickRightDown:
	inc bikeDL
	mov dl,bikeDL
	cmp dl,148 ;check if crash right wall
	jne noRightDownCrash
	movzx eax,crash
	call gotoxy
	call writeChar
	call writeChar
jmp done
	
noRightDownCrash:
	call gotoxy
	movzx eax,bikeLeftDown ;draw the right-down turn bike
	call writeChar
call changeBoard
cmp score,lengthof board
jge done
cmp crashEnd,1
je done
	
	movzx eax,delayBike
	call delay
	
	call gotoxy
	movzx eax,trailLeftDown ;draw the right-down trail
	call writeChar
	
	call readKey
	jz contTurnDown1
	
	mov dh,bikeDH
	mov dl,bikeDL
	
	cmp ah,001h ;escape pressed, quit game
	jne contDownEscape1
jmp done
contDownEscape1:
	
	cmp ah,039h ;spacebar pressed, pause game
	jne contDownPause1
	call pauseGame
contDownPause1:

	cmp ah,04Dh ;right arrow pressed, turn right
	jne contDownRight1
	mov dl,bikeDL
	jmp quickDownRight
contDownRight1:
	
	cmp ah,04Bh ;left arrow pressed, turn left
	jne contDownLeft1
	mov dl,bikeDL
	jmp quickDownLeft
contDownLeft1:
contTurnDown1:
	mov dh,bikeDH
	mov dl,bikeDL

	jmp afterTurnDown
	
turnLeftDown:
	mov dl,bikeDL
	mov dh,bikeDH
	call gotoxy
	movzx eax,trailHorz ;draw the trail where the bike was
	call writeChar
quickLeftDown:
	dec bikeDL
	mov dl,bikeDL
	cmp dl,1 ;check if crash left wall
	jne noLeftDownCrash
	movzx eax,crash
	call gotoxy
	call writeChar
	dec dl
	call gotoxy
	call writeChar
jmp done
	
noLeftDownCrash:
	call gotoxy
	movzx eax,bikeRightDown ;draw the right-down turn bike
	call writeChar
call changeBoard
cmp score,lengthof board
jge done
cmp crashEnd,1
je done
	
	movzx eax,delayBike
	call delay
	
	call gotoxy
	movzx eax,trailRightDown ;draw the right-down trail
	call writeChar
	
	call readKey
	jz contTurnDown2
	
	mov dh,bikeDH
	mov dl,bikeDL
	
	cmp ah,001h ;escape pressed, quit game
	jne contDownEscape2
jmp done
contDownEscape2:
	
	cmp ah,039h ;spacebar pressed, pause game
	jne contDownPause2
	call pauseGame
contDownPause2:

	cmp ah,04Dh ;right arrow pressed, turn right
	jne contDownRight2
	mov dl,bikeDL
	jmp quickDownRight
contDownRight2:
	
	cmp ah,04Bh ;left arrow pressed, turn left
	jne contDownLeft2
	mov dl,bikeDL
	jmp quickDownLeft
contDownLeft2:
contTurnDown2:
	mov dh,bikeDH
	mov dl,bikeDL

	jmp afterTurnDown
	
moveDown: ;moves the bike down one space
	mov dl,bikeDL
	mov dh,bikeDH
	call gotoxy
	movzx eax,trailVert ;draw the trail where the bike was
	call writeChar
	
afterTurnDown:
	inc bikeDH
	mov dh,bikeDH
	call gotoxy
	movzx eax,bikeVert ;draw bike at new location
	call writeChar
	call gotoxy
call changeBoard
cmp score,lengthof board
jge done
cmp crashEnd,1
je done
	
	cmp dh,61 ;check if crash bottom wall
	jne noDownCrash
	movzx eax,crash
	call writeChar
jmp done
	
noDownCrash:
	movzx eax,delayBike
	add eax,10
	call delay
	call readKey
	jz noKeyDown
	
	cmp ah,001h ;escape pressed, quit game
	jne aroundDownEscape
jmp done
aroundDownEscape:
	
	cmp ah,039h ;spacebar pressed, pause game
	jne aroundDownPause
	call pauseGame
aroundDownPause:
	
	cmp ah,04Dh ;right arrow pressed, turn right
	jne aroundDownRight
	jmp turnDownRight
aroundDownRight:
	
	cmp ah,04Bh ;left arrow pressed, turn left
	jne aroundDownLeft
	jmp turnDownLeft
aroundDownLeft:
noKeyDown:
jmp moveDown

done:
RET
lightBike ENDP


startGame PROC
	mov eax, lightmagenta+(lightgray*16)
	call SetTextColor
	
	mov dl,63 ;push space to start
	mov dh,31
	call gotoxy
	mov edx, OFFSET pushSpace
	call writeString
	
hitSpace: ;start the game
	movzx eax,delayReadKey
	call delay
	call readKey
	cmp ah,39h
jne hitSpace
	mov dl,63
	mov dh,31
	call gotoxy
	movzx eax,space
	mov ecx,24
erase:
	call writeChar
loop erase
;randomize starting spot here
	mov eax,14 ;random number from 0 to 13
	call randomRange
	inc eax    ;random number from 1 to 14
	add eax,23
	mov bikeDH,al ;random starting row
	
	mov eax,36 ;random number from 0 to 35
	call randomRange
	inc eax    ;random number from 1 to 36
	add eax,55
	mov bikeDL,al

	movzx eax,bikeHorz ;draw the starting bike location after spacebar is hit (currently moves left)
	mov dl,bikeDL
	mov dh,bikeDH
	call gotoxy
	call writeChar
	call gotoxy

RET
startGame ENDP


pauseGame PROC ;what it says
keepPaused:
	movzx eax, delayReadKey
	call delay
	call Readkey

	cmp ah, 39h
jne keepPaused ;if spacebar is hit, unpause. If not, keep paused

RET
pauseGame ENDP


controls PROC
	mov eax, white+(black*16)
	call SetTextColor
	
	mov dl,60
	mov dh,63
	call gotoxy
	mov edx,OFFSET controlMenu
	call writeString
	
	mov dl,60
	mov dh,64
	call gotoxy
	mov edx,OFFSET spc
	call writeString
	
	
	mov dl,60
	mov dh,65
	call gotoxy
	mov edx,OFFSET escp
	call writeString
	
	
	mov dl,60
	mov dh,66
	call gotoxy
	mov edx,OFFSET arro
	call writeString 
	
	mov dl,10
	mov dh,64
	call gotoxy
	mov edx,OFFSET levelStr
	call writeString
	
	mov dl,10
	mov dh,65
	call gotoxy
	mov edx,OFFSET totalStr
	call writeString
	
	mov dl,10
	mov dh,66
	call gotoxy
	mov edx,OFFSET scoreStr
	call writeString
	
RET
controls ENDP


showTRON PROC
	mov dl,72
	mov dh,31
	call gotoxy
	mov edx,OFFSET tronTitle
	mov eax, cyan+(black*16)
	call SetTextColor
	call writeString
	
hitSpace:
	movzx eax,delayReadKey
	call delay
	call readKey
	cmp ah,39h
jne hitSpace

RET
showTRON ENDP


drawBorder PROC
	mov eax, cyan+(lightgray*16)
	call SetTextColor
	
	mov dl,0 ;draws the gray background from top to bottom
	mov dh,0
	mov ecx,62
	movzx eax,space
drawBackground:
	push ecx
	mov ecx,150
	call gotoxy
	line:
		movzx eax,space
		call writeChar
	loop line
		movzx eax,delayBackground
		add eax,5
		call delay
	mov dl,0
	inc dh
	pop ecx
loop drawBackground
	movzx eax,wallTop ;top wall
	mov ecx,74

drawTopWall:
	mov dl,leftDL
	mov dh,leftDH
	call gotoxy
	call writeChar
	
	mov dl,rightDL
	mov dh,rightDH
	call gotoxy
	call writeChar
	
	dec leftDL
	inc rightDL
	
	push eax
	movzx eax,delayBackground
	call delay
	pop eax
loop drawTopWall
	
	mov ecx,60 ;side walls
	inc leftDH
	inc rightDH
	inc leftDL
	dec rightDL
drawSideWalls:
	mov dl,leftDL
	mov dh,leftDH
	call gotoxy
	movzx eax, wallBlock
	call writeChar
	inc leftDH
	
	mov dl,rightDL
	mov dh,rightDH
	call gotoxy
	movzx eax, wallBlock
	call writeChar
	inc rightDH
	
	push eax
	movzx eax,delayBackground
	add eax,5
	call delay
	pop eax
loop drawSideWalls

	movzx eax,wallBot ;bottom wall
	mov ecx,74

drawBotWall:
	mov dl,leftDL
	mov dh,leftDH
	call gotoxy
	call writeChar
	
	mov dl,rightDL
	mov dh,rightDH
	call gotoxy
	call writeChar
	
	inc leftDL
	dec rightDL
	
	push eax
	movzx eax,delayBackground
	call delay
	pop eax
loop drawBotWall
	
RET
drawBorder ENDP


createObstacle PROC
	pushad
	
	movzx ecx,nextLevel
obstacles:
	push ecx
	mov eax, cyan+(cyan*16)
	call SetTextColor
	;draw the top of the rectangle
	call drawTop

	;draw the middle of the rectangle
	call drawMid

	;draw bottom of the rectangle
	call drawBot
	pop ecx
loop obstacles
	
	mov eax, lightmagenta+(lightgray*16)
	call SetTextColor
	popad
RET
createObstacle ENDP

drawTop PROC
	mov eax,130 ;get random number 0-130
	call RandomRange
	add eax,2   ;change to 2-132
	mov ranX,al

	mov eax,45 ;get random number 0-44
	call RandomRange
	inc eax    ;change to 1-45
	mov ranY,al

	mov dl, ranX

	mov dh, ranY

	call Gotoxy ;print top left at the random coordinates
	mov al, topLeft
	call WriteChar
	
	call tangibleRectangle
	inc dl
	
	mov eax,10 ;0-9
	call randomRange
	add eax,5  ;5-14
	mov ecx,eax
	mov sideScreen,al
	dec sideScreen
	mov eax,0

	mov al, horiz ;print horizontal char random amount of times

topMid:
	call WriteChar
	call tangibleRectangle
	inc dl
LOOP topMid

	mov al, topRight ;print top right after random length
	call WriteChar
	call tangibleRectangle

	;call Clrscr

RET
drawTop ENDP

drawMid PROC
	mov dl,ranX
	mov eax,10 ;0-9
	call randomRange
	add eax,5  ;5-14
	mov ecx,eax
	mov botScreen,al
	dec botScreen
	mov eax,0

mid:
	INC dh

	call Gotoxy
	mov al,side
	call WriteChar
	call tangibleRectangle
	inc dl

	push ecx

	mov ecx, 0
	mov cl, sideScreen
	inc cl

	mov al, space

midSpace:
	call WriteChar
	call tangibleRectangle
	inc dl
LOOP midspace

	pop ecx

	mov al, side
	call WriteChar
	call tangibleRectangle
	mov dl,ranX

LOOP mid

RET
drawMid ENDP

drawBot PROC
	INC dh
	call Gotoxy
	mov al,botLeft
	call WriteChar
	call tangibleRectangle
	inc dl

	mov ecx, 0
	mov cl, sideScreen
	inc cl

	mov al, horiz

bot:
	call WriteChar
	call tangibleRectangle
	inc dl
LOOP bot

	mov al, botRight
	call WriteChar
	call tangibleRectangle
	mov dl,ranX

RET
drawBot ENDP


tangibleRectangle PROC
	push esi
	push eax
	push ebx
	
	mov esi,OFFSET board ;setup registers for 2d array math
	movzx eax,dh ;# of rows is 60
	mov ebx,146  ;# of columns is 146 (2 to 147)
	push edx
	mul ebx ;multiplys al which has the number of columns
	pop edx
	movzx ebx,dl
	add esi,eax
	add esi,ebx ;esi will have board OFFSET + (currentRow * #columns) + currentColumn
	
	mov BYTE ptr [esi],1
	
	pop ebx
	pop eax
	pop esi
RET
tangibleRectangle ENDP


startZone PROC
	push esi
	push eax
	push ebx
	
	mov dh,18
	mov dl,50
	mov ecx,46
reset:
	mov esi,OFFSET board ;setup registers for 2d array math
	movzx eax,dh ;# of rows is 60
	mov ebx,146  ;# of columns is 146 (2 to 147)
	push edx
	mul ebx ;multiplys al which has the number of columns
	pop edx
	movzx ebx,dl
	add esi,eax
	add esi,ebx ;esi will have board OFFSET + (currentRow * #columns) + currentColumn
	call gotoxy
fixZone:
	movzx eax,space
	call writeChar
	mov BYTE ptr [esi],0
	inc esi
loop fixZone

	cmp dh,42
	je around
	inc dh
	mov dl,50
	mov ecx,46
	jmp reset
around:
	
	pop ebx
	pop eax
	pop esi

RET
startZone ENDP


END main