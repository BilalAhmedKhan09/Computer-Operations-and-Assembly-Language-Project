INCLUDE Irvine32.inc

; Constants
ARRAY_SIZE EQU 10

.data
    Array           DWORD ARRAY_SIZE DUP(0)
    Msg_Title       BYTE "================= =================  Interactive Sorting and Searching System ================= =================",0
    Msg_Prompt_Input BYTE "Enter 10 integers: ",0
    Msg_Original    BYTE "Original Array: ",0
    Msg_Sorted      BYTE "Sorted Array:   ",0
    Msg_Choice_Sort BYTE "Choose Sort: 1=Selection 2=Shell 3=Insertion 4=Bubble 5=Comb : ",0
    Msg_Choice_Search BYTE "Choose Search: 1=Linear 2=Binary 3=Interpolation : ",0
    Msg_Target_Input BYTE "Enter number to find: ",0
    Msg_Found       BYTE "Found at index ",0
    Msg_NotFound    BYTE "Does not exist!",0
    Msg_Time        BYTE "Time Taken (ms) = ",0
    Msg_TryAgain    BYTE "Try again? (1=Yes, 0=No): ",0
    Space           BYTE " ",0
    
; Globals for Search Procedures (indices and target)
.data?
    l DWORD ?           ; Low index (used by Binary/Interpolation)
    h DWORD ?           ; High index (used by Binary/Interpolation)
    mid DWORD ?         ; Mid index (used by Binary)
    pos DWORD ?         ; Calculated position (used by Interpolation)
    targetVal DWORD ?   ; Target value for searches
    SortChoice    DWORD ?
    SearchChoice  DWORD ?
    StartTime     DWORD ?
    EndTime       DWORD ?
    ElapsedTime   DWORD ?

.code


;         // PrintArray Function // :


PrintArray PROC
    PUSHAD
    mov esi, OFFSET Array
    mov ecx, ARRAY_SIZE
print_loop:
    mov eax, [esi]
    call WriteInt
    mov edx, OFFSET Space
    call WriteString
    add esi, TYPE Array
    loop print_loop
    call CrLf
    POPAD
    ret
PrintArray ENDP


;          // SORTING ALGORITHMS // :

;          // Selection Sort // :


SelectionSort PROC
    PUSHAD
    mov esi, OFFSET Array      ; ESI = base of Array
    mov ecx, ARRAY_SIZE        ; ECX = total array size
    mov edi, 0                 ; EDI = outer loop index i

SelOuter:
    cmp edi, ecx
    jge SelDone

    mov ebx, edi               ; EBX = min_idx = i
    mov edx, edi
    inc edx                    ; EDX = j = i + 1 (inner loop index)

SelInner:
    cmp edx, ecx
    jge SelInnerDone

    ; Compare Array[j] with Array[min_idx]
    mov eax, [esi + edx*TYPE Array] ; eax = Array[j]
    cmp eax, [esi + ebx*TYPE Array] ; compare with Array[min_idx]
    jge SelNextJ

    mov ebx, edx               ; min_idx = j
SelNextJ:
    inc edx
    jmp SelInner

SelInnerDone:
    ; Swap Array[i] and Array[min_idx] if needed
    cmp ebx, edi
    je SelNoSwap

    mov eax, [esi + edi*TYPE Array] ; temp = Array[i]
    mov edx, [esi + ebx*TYPE Array] ; Array[min_idx]
    mov [esi + edi*TYPE Array], edx ; Array[i] = Array[min_idx]
    mov [esi + ebx*TYPE Array], eax ; Array[min_idx] = temp
SelNoSwap:
    inc edi
    jmp SelOuter

SelDone:
    POPAD
    ret
SelectionSort ENDP



;               // Shell Sort // : 



ShellSort PROC
    PUSHAD
    mov esi, OFFSET Array
    mov ecx, ARRAY_SIZE
    shr ecx, 1              ; initial gap = N / 2

ShellGap:
    cmp ecx, 0
    je ShellDone            ; gap = 0 -> done
    mov ebx, ecx            ; EBX = gap

    mov edi, ebx            ; i = gap
ShellOuter:
    cmp edi, ARRAY_SIZE
    jge ShellNextGap

    mov eax, [esi + edi*TYPE Array] ; key = Array[i]
    mov edx, edi                    ; j = i

ShellInner:
    cmp edx, ebx
    jl ShellInsertKey

    mov ebp, edx
    sub ebp, ebx                     ; EBX = gap, EBP = j - gap
    mov ebp, [esi + ebp*TYPE Array] ; Array[j - gap]
    cmp ebp, eax
    jle ShellInsertKey

    mov [esi + edx*TYPE Array], ebp  ; shift element forward
    sub edx, ebx
    jmp ShellInner

ShellInsertKey:
    mov [esi + edx*TYPE Array], eax
    inc edi
    jmp ShellOuter

ShellNextGap:
    shr ecx, 1                        ; gap = gap / 2
    jmp ShellGap

ShellDone:
    POPAD
    ret
ShellSort ENDP




;                // Insertion Sort //



InsertionSort PROC
    PUSHAD
    mov esi, OFFSET Array
    mov ecx, ARRAY_SIZE
    mov edi, 1              ; i = 1

InsOuter:
    cmp edi, ecx
    jge InsDone

    mov eax, [esi + edi*TYPE Array] ; key = Array[i]
    mov ebx, edi                    ; j = i

InsInner:
    cmp ebx, 0
    je InsInsert

    mov edx, ebx
    dec edx
    mov edx, [esi + edx*TYPE Array] ; edx = Array[j-1]
    cmp edx, eax
    jle InsInsert

    mov [esi + ebx*TYPE Array], edx ; shift Array[j-1] -> Array[j]
    dec ebx
    jmp InsInner

InsInsert:
    mov [esi + ebx*TYPE Array], eax ; insert key at position j
    inc edi
    jmp InsOuter

InsDone:
    POPAD
    ret
InsertionSort ENDP




;            // Bubble Sort //



BubbleSort PROC
    PUSHAD
    mov ecx, ARRAY_SIZE
BubbleOuter:
    cmp ecx, 1
    jle BubbleDone          ; Check passes > 1
    
    mov esi, OFFSET Array
    mov ebx, ecx
    dec ebx                 ; ebx = comparisons per pass (N-i-1)
    
BubbleInner:
    cmp ebx, 0
    jle BubbleNextOuter     ; Check comparisons > 0
    
    ; Compare [ESI] with [ESI + 4]
    mov eax, [esi]
    mov edx, [esi + TYPE Array]
    cmp eax, edx
    jbe BubbleNoSwap
    
    ; Swap
    mov [esi], edx
    mov [esi + TYPE Array], eax
BubbleNoSwap:
    add esi, TYPE Array
    dec ebx
    jmp BubbleInner
    
BubbleNextOuter:
    dec ecx                 ; Next pass
    jmp BubbleOuter

BubbleDone:
    POPAD
    ret
BubbleSort ENDP


;          // Comb Sort // : 


CombSort PROC
    PUSHAD
    mov ebx, ARRAY_SIZE     ; ebx = gap (start with N)
    mov edi, 1              ; edi = swapped = true (to ensure first pass runs)

CombOuter:
    ; 1. Calculate new gap = (gap * 10) / 13
    mov eax, ebx            ; EAX = current gap
    mov ecx, 10
    imul ecx                ; EDX:EAX = EAX * 10
    mov ecx, 13
    xor edx, edx            ; Clear EDX for division
    div ecx                 ; EAX = new gap
    
    mov ebx, eax            ; ebx = new gap
    cmp ebx, 1
    jge CombGapOK
    mov ebx, 1              ; If gap < 1, set gap = 1

CombGapOK:
    mov edi, 0              ; swapped = false for this pass
    
    ; 2. Inner loop counter check: i < N - gap
    mov ecx, ARRAY_SIZE
    sub ecx, ebx            ; ECX = comparisons to make
    
    mov esi, OFFSET Array   ; ESI = start of array
    mov edx, ebx            ; EDX = gap 
    imul edx, TYPE Array    ; EDX = gap * 4 (offset in bytes)

CombInnerLoop:
    cmp ecx, 0
    je CombInnerDone        ; Check if loop finished
    
    ; Compare Array[i] with Array[i + gap]
    mov eax, [esi]
    mov ebp, [esi + edx]    ; EBP = Array[i + gap]
    cmp eax, ebp
    jbe CombNoSwap
    
    ; Swap
    mov [esi], ebp
    mov [esi + edx], eax
    mov edi, 1              ; swapped = true
CombNoSwap:
    add esi, TYPE Array     ; Move to next element (i++)
    loop CombInnerLoop      ; Decrement ECX, repeat
    
CombInnerDone:
    ; 3. Check termination
    cmp ebx, 1              ; Check if gap is 1
    jne CombOuter           ; If gap > 1, loop back to shrink gap
    cmp edi, 1              ; Check if swapped is true
    je CombOuter            ; If gap=1 and swapped=true, loop for bubble pass
    
    ; Finished
    POPAD
    ret
CombSort ENDP


;                          // SEARCHING ALGORITHMS // : 



;          // Linear Search //:



LinearSearch PROC
    PUSHAD
    mov esi, OFFSET Array
    mov ecx, ARRAY_SIZE
    mov ebx, targetVal      ; EBX = target
    xor edi, edi            ; EDI = index counter

LinearLoop:
    cmp edi, ARRAY_SIZE
    jge LinearNotFound      ; End of array, not found

    mov eax, [esi + edi*TYPE Array]
    cmp eax, ebx
    je LinearFound

    inc edi
    jmp LinearLoop

LinearFound:
    mov edx, OFFSET Msg_Found
    call WriteString
    mov eax, edi            ; index = EDI
    call WriteDec
    call CrLf
    jmp LinearDone

LinearNotFound:
    mov edx, OFFSET Msg_NotFound
    call WriteString
    call CrLf

LinearDone:
    POPAD
    ret
LinearSearch ENDP



;   // Binary Search // : 



BinarySearch PROC
    PUSHAD
    mov DWORD PTR l, 0                  ; l = 0
    mov eax, ARRAY_SIZE
    dec eax
    mov DWORD PTR h, eax                ; h = N - 1
    mov ebp, targetVal                  ; EBP = target

BinWhile:
    mov eax, DWORD PTR l
    cmp eax, DWORD PTR h
    jg BinNotFound                      ; Check l <= h

    ; mid = l + (h - l) / 2
    mov eax, DWORD PTR h
    sub eax, DWORD PTR l
    mov ebx, 2
    xor edx, edx
    div ebx                             ; EAX = (h-l)/2
    add eax, DWORD PTR l
    mov DWORD PTR mid, eax              ; mid = EAX

    ; Compare Array[mid] with target
    mov esi, OFFSET Array
    mov eax, DWORD PTR mid
    mov ecx, [esi + eax*TYPE Array]     ; ECX = Array[mid]
    cmp ecx, ebp
    je BinFound
    
    jl BinMoveLow                       ; Array[mid] < target -> l = mid + 1
    
    ; Array[mid] > target -> h = mid - 1
    mov eax, DWORD PTR mid
    dec eax
    mov DWORD PTR h, eax
    jmp BinWhile
    
BinMoveLow:
    ; l = mid + 1
    mov eax, DWORD PTR mid
    inc eax
    mov DWORD PTR l, eax
    jmp BinWhile

BinFound:
    mov edx, OFFSET Msg_Found
    call WriteString
    mov eax, DWORD PTR mid
    call WriteDec
    call CrLf
    jmp BinDone
    
BinNotFound:
    mov edx, OFFSET Msg_NotFound
    call WriteString
    call CrLf

BinDone:
    POPAD
    ret
BinarySearch ENDP




;   // Interpolation Search // : 



InterpolationSearch PROC
    PUSHAD
    mov DWORD PTR l, 0
    mov eax, ARRAY_SIZE
    dec eax
    mov DWORD PTR h, eax
    mov ebp, targetVal      ; target in EBP

IS_while:
    mov eax, DWORD PTR l
    cmp eax, DWORD PTR h
    jg IS_NotFound

    mov esi, OFFSET Array
    mov edx, DWORD PTR l
    mov edx, [esi + edx*TYPE Array]    ; Array[l]
    mov ecx, DWORD PTR h
    mov ecx, [esi + ecx*TYPE Array]    ; Array[h]

    cmp ebp, edx
    jb IS_NotFound
    cmp ebp, ecx
    ja IS_NotFound

    cmp edx, ecx
    je IS_SpecialCheck

    ; pos = l + ((target - Array[l]) * (h - l)) / (Array[h] - Array[l])
    mov eax, ebp
    sub eax, edx           ; target - Array[l]
    mov ebx, DWORD PTR h
    sub ebx, DWORD PTR l   ; h - l
    imul ebx               ; 64-bit result in EDX:EAX
    mov ebx, ecx           ; Denominator = Array[h] - Array[l]
    sub ebx, edx
    xor edx, edx           ; Clear EDX before division
    div ebx                ; EAX = quotient
    add eax, DWORD PTR l
    ; Ensure pos is within bounds
    cmp eax, 0
    jl IS_NotFound
    cmp eax, ARRAY_SIZE-1
    jg IS_NotFound
    mov DWORD PTR pos, eax

IS_Compare:
    mov eax, DWORD PTR pos
    mov ecx, [esi + eax*TYPE Array]
    cmp ecx, ebp
    je IS_Found

    jl IS_MoveLow
    mov eax, DWORD PTR pos
    dec eax
    mov DWORD PTR h, eax
    jmp IS_while

IS_MoveLow:
    mov eax, DWORD PTR pos
    inc eax
    mov DWORD PTR l, eax
    jmp IS_while

IS_SpecialCheck:
    cmp ebp, edx
    je IS_Found
    jmp IS_NotFound

IS_Found:
    mov edx, OFFSET Msg_Found
    call WriteString
    mov eax, DWORD PTR pos
    call WriteDec
    call CrLf
    jmp IS_Done

IS_NotFound:
    mov edx, OFFSET Msg_NotFound
    call WriteString
    call CrLf

IS_Done:
    POPAD
    ret
InterpolationSearch ENDP


;                                    // MAIN FUNCTION //   : 

main PROC
    call Clrscr
MainLoop:
    ; Title
    call CrLf
    mov edx, OFFSET Msg_Title
    call WriteString
    call CrLf

    ; Input array
    mov edx, OFFSET Msg_Prompt_Input
    call WriteString
    call CrLf
    mov esi, OFFSET Array
    mov ecx, ARRAY_SIZE
InputLoop:
    call ReadInt
    mov [esi], eax
    add esi, TYPE Array
    loop InputLoop

    ; Display original array
    mov edx, OFFSET Msg_Original
    call WriteString
    call PrintArray

    ; --- Choose Sort ---
    mov edx, OFFSET Msg_Choice_Sort
    call WriteString
    call ReadInt
    mov SortChoice, eax          ; Save choice in variable

    ; Get start time for sorting
    call GetMseconds
    mov StartTime, eax

    ; Call sorting procedure based on choice
    mov eax, SortChoice
    cmp eax, 1
    je DoSelection
    cmp eax, 2
    je DoShell
    cmp eax, 3
    je DoInsertion
    cmp eax, 4
    je DoBubble
    cmp eax, 5
    je DoComb
    ; Default to InsertionSort if invalid
DoInsertion:
    call InsertionSort
    jmp SortEnd
DoSelection:
    call SelectionSort
    jmp SortEnd
DoShell:
    call ShellSort
    jmp SortEnd
DoBubble:
    call BubbleSort
    jmp SortEnd
DoComb:
    call CombSort

SortEnd:
    call GetMseconds
    mov EndTime, eax
    mov eax, EndTime
    sub eax, StartTime
    mov ElapsedTime, eax

    ; Display sorted array and time
    mov edx, OFFSET Msg_Sorted
    call WriteString
    call PrintArray
    mov edx, OFFSET Msg_Time
    call WriteString
    mov eax, ElapsedTime
    call WriteInt
    call CrLf

    ; --- Input target ---
    mov edx, OFFSET Msg_Target_Input
    call WriteString
    call ReadInt
    mov targetVal, eax          ; Save target

    ; --- Choose Search ---
    mov edx, OFFSET Msg_Choice_Search
    call WriteString
    call ReadInt
    mov SearchChoice, eax       ; Save search choice

    ; Get start time for search
    call GetMseconds
    mov StartTime, eax

    ; Call search procedure
    mov eax, SearchChoice
    cmp eax, 1
    je DoLinear
    cmp eax, 2
    je DoBinary
    cmp eax, 3
    je DoInterpolation
    ; Default to Linear if invalid
DoLinear:
    call LinearSearch
    jmp SearchEnd
DoBinary:
    call BinarySearch
    jmp SearchEnd
DoInterpolation:
    call InterpolationSearch

SearchEnd:
    call GetMseconds
    mov EndTime, eax
    mov eax, EndTime
    sub eax, StartTime
    mov ElapsedTime, eax

    ; Display search time
    mov edx, OFFSET Msg_Time
    call WriteString
    mov eax, ElapsedTime
    call WriteInt
    call CrLf

    ; Ask to try again
    call CrLf
    mov edx, OFFSET Msg_TryAgain
    call WriteString
    call ReadInt
    cmp eax, 1
    je MainLoop
    jmp ExitProgram

ExitProgram:
    exit
main ENDP
END main

