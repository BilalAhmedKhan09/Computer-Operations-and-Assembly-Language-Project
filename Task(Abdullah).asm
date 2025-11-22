INCLUDE Irvine32.inc

.data
    Array       DWORD 10 DUP(0)
    Msg_Title   BYTE "======== Sorting ========",0
    Msg_Prompt  BYTE "Enter 10 integers: ",0
    Msg_Original BYTE "Original Array: ",0
    Msg_Bubble  BYTE "Bubble Sorted: ",0
    Msg_Comb    BYTE "Comb Sorted:   ",0
    Msg_Time    BYTE "Time taken (ms): ",0
    Space       BYTE " ",0

.code

;           // Bubble Sort //:

BubbleSort PROC
    mov ecx, 10              ; outer loop counter
outer_loop:
    mov esi, OFFSET Array
    mov ebx, 9               ; inner loop counter
inner_loop:
    mov eax, dword ptr [esi]       ; A[i]
    mov edx, dword ptr [esi+4]     ; A[i+1]
    cmp eax, edx
    jbe no_swap
    mov dword ptr [esi], edx
    mov dword ptr [esi+4], eax
no_swap:
    add esi, 4
    dec ebx
    jnz inner_loop
    loop outer_loop
    ret
BubbleSort ENDP

;       // Comb Sort //

CombSort PROC
    mov ebx, 10          ; initial gap
    mov ecx, 1           ; swapped = true

comb_outer:
    ; gap = gap * 10 / 13
    mov eax, ebx
    imul eax, 10
    xor edx, edx
    mov edi, 13
    div edi
    mov ebx, eax
    cmp ebx, 1
    jge gap_ok
    mov ebx, 1
gap_ok:
    mov ecx, 0           ; swapped = false
    mov esi, OFFSET Array

comb_inner:
    mov eax, dword ptr [esi]
    mov edx, dword ptr [esi + ebx*4]
    cmp eax, edx
    jbe no_swap2
    mov dword ptr [esi], edx
    mov dword ptr [esi + ebx*4], eax
    mov ecx, 1                ; swapped = true
no_swap2:
    add esi, 4                ; move to next element

    ; Calculate last valid index =Array+(9-gap)*4
    mov edi,OFFSET Array      ;base of array
    mov eax, 9
    sub eax, ebx               ; 9-gap
    imul eax, 4                ; (9-gap)*4
    add edi, eax               ; edi= Array +(9-gap)*4

    cmp esi, edi               ; compare current index with last valid
    jle comb_inner             ; continue inner loop if esi <= last valid


    cmp ebx, 1
    jne comb_outer        ; if gap>1, continue
    cmp ecx, 1
    je comb_outer         ; if swapped=true, continue
    ret
CombSort ENDP

;      // Print Array //

PrintArray PROC
    mov esi, OFFSET Array
    mov ecx, 10
print_loop:
    mov eax, dword ptr [esi]
    call WriteInt
    mov edx, OFFSET Space
    call WriteString
    add esi, 4
    loop print_loop
    call CrLf
    ret
PrintArray ENDP

;           // Main Function:

main PROC
    mov edx, OFFSET Msg_Title
    call WriteString
    call CrLf

;Input Array:

    mov edx, OFFSET Msg_Prompt
    call WriteString
    call CrLf
    mov esi, OFFSET Array
    mov ecx, 10
input_loop:
    call ReadInt
    mov dword ptr [esi], eax
    add esi, 4
    loop input_loop

;Print Original Array:

    mov edx, OFFSET Msg_Original
    call WriteString
    call PrintArray

;Bubble Sort:

    call GetMseconds
    mov ebx, eax
    call BubbleSort
    call GetMseconds
    sub eax, ebx
    mov edx, OFFSET Msg_Bubble
    call WriteString
    call PrintArray
    mov edx, OFFSET Msg_Time
    call WriteString
    call WriteInt
    call CrLf

;Reset Array for Comb Sort:

    mov esi, OFFSET Array
    mov ecx, 10
reset_loop:
    mov dword ptr [esi], 0
    add esi, 4
    loop reset_loop

;Input Array Again for Comb Sort:
 
    mov edx, OFFSET Msg_Prompt
    call WriteString
    call CrLf
    mov esi, OFFSET Array
    mov ecx, 10
input_loop2:
    call ReadInt
    mov dword ptr [esi], eax
    add esi, 4
    loop input_loop2

;Comb Sort:

    call GetMseconds
    mov ebx, eax
    call CombSort
    call GetMseconds
    sub eax, ebx
    mov edx, OFFSET Msg_Comb
    call WriteString
    call PrintArray
    mov edx, OFFSET Msg_Time
    call WriteString
    call WriteInt
    call CrLf

    exit
main ENDP

END main
