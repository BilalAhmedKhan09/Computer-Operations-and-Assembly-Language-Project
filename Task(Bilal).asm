Include Irvine32.inc

.Data
    Array Dword 10 Dup(0)
    Msg_Title      Byte "   Sort With User Input", 0
    Msg_Prompt     Byte "Enter 10 Integers To Sort", 0
    Msg_Original   Byte "Original Array: ", 0
    Msg_Sorted     Byte "Sorted Array:   ", 0
    Msg_Choice     Byte "Enter 1 for Selection Sort, 2 for Shell Sort, and any other for Insertion Sort: ", 0
    Msg_Time       Byte "Time taken (ms): ", 0

.Code
DisplayArray Proc
    Mov Ecx, Lengthof Array
    L1: 
        Cmp ECX, 0
        Je  L2

        ; Display The Current Element: [ESI]
        Mov EAX, [ESI]
        Call WriteInt

        ; Print a separator space
        Mov AL, ' '
        Call WriteChar

        Add ESI, Type Array 
        Loop L1

    L2: ; End Of Display Loop
    Call Crlf
    Ret
DisplayArray Endp

ShellSort Proc
    ; Registers used: EAX (key), EBX (j index), EDI (i index), ESI (array base), EDX (gap)
    Mov ECX, Lengthof Array
    Mov ESI, Offset Array
    Mov EDX, ECX
    Shr EDX, 1                 ; to make gap = size / 2
    Gap:
        Cmp EDX, 0
        Je  Done               ;Once Gap is 0, sorting is done
        Mov EDI, EDX
    Iloop:                  ;Loop for i = gap to size-1
        Cmp EDI, ECX
        jge GapHalf
        Mov EBX, EDI
        Mov EAX, [ESI + EDI * Type Array]   ;Key = Array[i]
    Jloop:                  ;Loop to shift elements
        Cmp EBX, EDX
        Jl  InsertKey
        Mov EBP, EBX                ;temporarily holds j
        Sub EBP, EDX                ;j - gap
        Mov EBP, [ESI + EBP * Type Array] ;Array[j - gap]
        Cmp EBP, EAX               ;Compare Array[j - gap] with key
        Jle InsertKey
        Mov [ESI + EBX * Type Array], EBP   ;Array[j] = Array[j - gap]
        Sub EBX, EDX        ; j = j - gap
        Jmp JLoop
    InsertKey:
        Mov [ESI + EBX * Type Array], EAX
        Inc EDI
        Jmp ILoop          ;Continue for every pair at start and start + gap
    GapHalf:
    Shr EDX, 1              ;Reduce gap by half
    Jmp Gap
    Done:
    Ret
ShellSort Endp

InsertionSort Proc
    ; Registers used: EAX (key), EBX (j index), EDI (i index), ESI (array base)

    ; Outer loop setup (i = 1; i < size; i++)
    Mov ESI, Offset Array     
    Mov ECX, Lengthof Array    
    Mov EDI, 1                 

OuterLoop:
    Cmp EDI, ECX               ; if i >= size, we are done
    Jge SortDone

    ; 1. Store The Key: EAX = Key = Array[I]
    Mov EAX, [ESI + EDI * Type Array] 

    ; 2. Initialize inner loop index: EBX = j = i
    Mov EBX, EDI

InnerLoop:
    ; Check 1: Boundary condition (j > 0)
    Cmp EBX, 0                 ; if j == 0, stop shifting
    Je  InsertKey              

    ; Get The Element To The Left: EDX = Array[j-1]
    Mov EDX, [ESI + EBX * Type Array - Type Array] 

    ; Check 2: Comparison condition (Array[j-1] > key)
    Cmp EDX, EAX               ; If Array[j-1] <= key, stop shifting
    Jle InsertKey

    ; 3. Shift operation: Array[j] = Array[j-1]
    Mov [ESI + EBX * Type Array], EDX  

    Dec EBX
    Jmp InnerLoop

InsertKey:
    ; 5. Insertion step: Array[j] = key 
    Mov [ESI + EBX * Type Array], EAX   

    ; Increment i and continue the outer loop
    Inc EDI                     
    Jmp OuterLoop

SortDone:
    Ret
InsertionSort Endp


SelectionSort Proc
    ; registers used: esi (array base), edi (i index), ebx (j index), edx (min_idx), eax (temp)

    Mov ESI, Offset Array       
    Mov ECX, Lengthof Array     
    Mov EDI, 0                  

OuterLoop:
    Cmp EDI, ECX                ; check if i < size
    Jge SortDone                ; done sorting
    Mov EDX, EDI                ; edx = min_idx = i
    Mov EBX, EDI                ; start inner loop index j at i+1

InnerLoopSetup:
    Inc EBX                     ; j = i + 1

InnerLoop:
    Cmp EBX, ECX                ; check if j < size
    Jge InnerLoopDone           ; if j >= size, we finished the search

    ; compare every arr[j] with arr[min_idx]
    Mov EAX, [ESI + EBX * Type Array] ; eax = arr[j]
    Cmp EAX, [ESI + EDX * Type Array]
    Jge NextJ                   ; if arr[j] >= arr[min_idx], keep the current min_idx
    
    Mov EDX, EBX               ; if arr[j] is smaller, update min_idx

NextJ:
    Inc EBX                    
    Jmp InnerLoop

InnerLoopDone:
    ; 2. swap arr[i] with arr[min_idx] if min_idx != i
    Cmp EDX, EDI                ; check if min_idx != i
    Je  OuterLoopNext           ; if they are equal, no swap needed

    Mov EAX, [ESI + EDI * Type Array]           ; perform the swap: temp = arr[i]
    
    Mov EBX, [ESI + EDX * Type Array]           ; arr[i] = arr[min_idx]
    Mov [ESI + EDI * Type Array], EBX
    
    Mov [ESI + EDX * Type Array], EAX           ; arr[min_idx] = temp (eax)

OuterLoopNext:
    Inc EDI                     
    Jmp OuterLoop

SortDone:
    Ret
SelectionSort Endp



Main Proc
    Mov EDX, Offset Msg_Title
    Call WriteString
    Call Crlf
    Mov EDX, Offset Msg_Prompt
    Call WriteString
    Call Crlf

    Mov ECX, Lengthof Array
    Mov ESI, Offset Array
Input:
    Call ReadInt                
    Mov [ESI], EAX              
    Add ESI, Type Array         
    Loop Input

    ; Reset registers for DisplayArray (original array)
    Mov ECX, Lengthof Array
    Mov ESI, Offset Array
    Mov EDX, Offset Msg_Original
    Call WriteString
    Call DisplayArray

    Mov EDX, Offset Msg_Choice
    Call WriteString
    Call ReadInt            ;If user inputs 1, use selection sort
    Cmp eax, 1
    Je  UseSelectionSort
    Cmp eax, 2
    Je  UseShellSort

        Call GetMseconds            ;Start Time 
        Push EAX                    ;Save Start Time 

        Call InsertionSort

        Call GetMseconds            ;End Time 
        Pop EBX                     ;Start Time 
        Sub EAX, EBX                ;Get DUration
    jmp Display

    UseShellSort:
        Call GetMseconds            ; EAX = Start Time 
        Push EAX                    ; Save Start Time 

        Call ShellSort

        Call GetMseconds            ;End Time 
        Pop EBX                     ;Start Time 
        Sub EAX, EBX                ;Get DUration

        Jmp Display

    UseSelectionSort:
        Call GetMseconds            ; EAX = Start Time 
        Push EAX                    ; Save Start Time 

        Call SelectionSort

        Call GetMseconds            ;End Time 
        Pop EBX                     ;Start Time 
        Sub EAX, EBX                ;Get DUration

        Jmp Display

    ; Reset registers for DisplayArray (sorted array)
    Display:
        Mov ESI, Offset Array
        Mov EDX, Offset Msg_Sorted
        Call WriteString
        Call DisplayArray
        Mov EDX, Offset Msg_Time
        Call WriteString
        Call WriteInt

    Exit
Main Endp

End Main
