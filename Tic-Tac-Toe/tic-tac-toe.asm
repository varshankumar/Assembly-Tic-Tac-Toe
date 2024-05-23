INCLUDE Irvine32.inc

.data
gameBoard db 9 dup('?')
player db 'X'
winMsgX db "Player X wins!", 0
winMsgO db "Player O wins!", 0
drawMsg db "It's a draw!", 0
promptMsg db "Enter position (1-9) or 0 to undo: ", 0
invalidMsg db "Invalid move, try again.", 0
undoMsg db "Last move undone.", 0
noUndoMsg db "No move to undo.", 0
position db ?
moveStack db 9 dup(0FFh)
stackTop db 0

.code
main PROC
call Clrscr
call DrawBoard
xor ebx, ebx

MainLoop :
call GetPlayerMove
call DrawBoard
call CheckWin
jnz PlayerWin
call CheckDraw
cmp eax, 0
jnz GameDraw
call SwitchPlayer
jmp MainLoop

PlayerWin :
cmp player, 'X'
je DisplayXWin
mov edx, OFFSET winMsgO
jmp DisplayWin

DisplayXWin :
mov edx, OFFSET winMsgX

DisplayWin :
call Crlf
call WriteString
call Crlf
jmp EndGame

GameDraw :
call Crlf
mov edx, OFFSET drawMsg
call WriteString
call Crlf

EndGame :
invoke ExitProcess, 0

DrawBoard PROC
mov edx, OFFSET gameBoard
mov ecx, LENGTHOF gameBoard
mov esi, 0

DrawLoop:
mov al, byte ptr[edx + esi]
call WriteChar
inc esi
cmp esi, 3
je DrawNewLine
cmp esi, 6
je DrawNewLine
cmp esi, 9
je EndDrawLoop
jmp DrawLoop

DrawNewLine :
call Crlf
jmp DrawLoop

EndDrawLoop :
ret
DrawBoard ENDP

GetPlayerMove PROC
call Crlf
mov edx, OFFSET promptMsg
call WriteString
call ReadDec
mov eax, eax
dec eax
cmp eax, -1
je UndoLastMove
cmp eax, 8
ja InvalidMove
movzx ecx, al
mov al, player
cmp byte ptr[gameBoard + ecx], '?'
jne InvalidMove
mov[gameBoard + ecx], al

inc ebx

movzx edx, stackTop
mov byte ptr[moveStack + edx], cl
inc stackTop

ret

InvalidMove :
mov edx, OFFSET invalidMsg
call WriteString
call Crlf
jmp GetPlayerMove
GetPlayerMove ENDP

UndoLastMove PROC
cmp stackTop, 0
je NoMoveToUndo

dec stackTop
movzx ecx, stackTop
movzx edx, byte ptr[moveStack + ecx]
mov byte ptr[gameBoard + edx], '?'

dec ebx

call Crlf
mov edx, OFFSET undoMsg
call WriteString
call Crlf
ret

NoMoveToUndo :
call Crlf
mov edx, OFFSET noUndoMsg
call WriteString
call Crlf
ret
UndoLastMove ENDP

CheckWin PROC
mov ecx, 0
CheckRows:
movzx eax, byte ptr gameBoard[ecx]
movzx edx, byte ptr gameBoard[ecx + 1]
cmp eax, edx
jne ContinueCheck
movzx edx, byte ptr gameBoard[ecx + 2]
cmp eax, edx
jne ContinueCheck
cmp al, '?'
je ContinueCheck
mov eax, 1
ret
ContinueCheck :
add ecx, 3
cmp ecx, 9
jb CheckRows

mov ecx, 0
CheckColumns :
	movzx eax, byte ptr gameBoard[ecx]
	movzx edx, byte ptr gameBoard[ecx + 3]
	cmp eax, edx
	jne ContinueCheck2
	movzx edx, byte ptr gameBoard[ecx + 6]
	cmp eax, edx
	jne ContinueCheck2
	cmp al, '?'
	je ContinueCheck2
	mov eax, 1
	ret
	ContinueCheck2 :
inc ecx
cmp ecx, 3
jb CheckColumns

movzx eax, byte ptr gameBoard[0]
movzx edx, byte ptr gameBoard[4]
cmp eax, edx
jne CheckDiagonal2
movzx edx, byte ptr gameBoard[8]
cmp eax, edx
jne CheckDiagonal2
cmp al, '?'
je CheckDiagonal2
mov eax, 1
ret

CheckDiagonal2 :
movzx eax, byte ptr gameBoard[2]
movzx edx, byte ptr gameBoard[4]
cmp eax, edx
jne NoWin
movzx edx, byte ptr gameBoard[6]
cmp eax, edx
jne NoWin
cmp al, '?'
je NoWin
mov eax, 1
ret

NoWin :
xor eax, eax
ret
CheckWin ENDP

CheckDraw PROC
cmp ebx, 9
jne NotDraw
mov eax, 1
ret

NotDraw :
xor eax, eax
ret
CheckDraw ENDP

SwitchPlayer PROC
cmp player, 'X'
je SetPlayerO
mov player, 'X'
ret

SetPlayerO :
mov player, 'O'
ret
SwitchPlayer ENDP

main ENDP
END main
