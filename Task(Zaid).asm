include irvine32.inc

.data
array dword 10, 15, 24, 32, 56
left dword ?
right dword ?
mid dword ?
l dword ?
h dword ?
pos dword ?
target dword ?
targetInput byte "Enter number to find: ", 0
found byte "Found at index ", 0
notFound byte "Does not exist!", 0
timeMsg byte "Time Taken (ms) = ",0
.code

LinearSearch proc

    mov esi, offset array
    mov eax, lengthof array
    mov ecx, eax
    mov eax, target                 ; load target into register for comparison

loopArray:
    cmp ecx, 0
    je Linear_notFoundLabel                ; if no elements left, not found
    cmp [esi], eax
    je Linear_foundLabel                   ; if number found, jump

    add esi, type array             ; keep looping until number found
    dec ecx
    jmp loopArray

Linear_foundLabel:
    mov edx, offset found
    call writestring                ; if number found, print found
    mov eax, lengthof array
    sub eax, ecx
    call writedec                   ; index at which element is stored
    call crlf
    ret

Linear_notFoundLabel:
    mov edx, offset notFound
    call writestring
    call crlf
    ret

LinearSearch endp


BinarySearch proc

    mov left, 0  
    mov eax, lengthof array
    dec eax
    mov right, eax                  ;left and right most index initializations

    whileLoop:
        mov eax, right
        cmp left, eax
        jg Binary_notFoundLabel                    ;check if left is less than or equal to right, in which case program ends if no value is found
        
        mov eax, right
        sub eax, left

        mov ebx, 2
        xor edx, edx
        div ebx

        add eax, left

        mov mid, eax                        ;calculating mid: mid = left + (right - left) / 2

        mov eax, target
        mov ebx, mid
        imul ebx, type array
        cmp [array + ebx], eax              ;if mid value = target then value found
        jne l1

        mov edx, offset found
        call writestring                
        mov eax, mid                        ;printing value found and the index
        call writedec
        call crlf
        ret                                 

        l1:                                 
            mov eax, target
            mov ebx, mid
            imul ebx, type array
            cmp [array + ebx], eax
            jge l2                          ;comparing arr[mid] and target

            mov eax, mid
            inc eax
            mov left, eax                   ;left = mid + 1
            jmp whileLoop

        l2:
            mov eax, mid
            dec eax
            mov right, eax                  ;right = mid - 1
            jmp whileLoop
        

    Binary_notFoundLabel:
        mov edx, offset notFound
        call writestring
        ret

BinarySearch endp


InterpolationSearch proc

    mov l, 0
    mov eax, lengthof array
    dec eax
    mov h, eax                           ;initialize low and high     

    IS_whileLoop:
        mov eax, l
        cmp eax, h
        ja IS_notFoundLabel                  ; exit if low > high

        ; check if target is within arr[low]..arr[high]
        mov eax, target
        mov ebx, l
        imul ebx, 4
        cmp eax, [array + ebx]
        jb IS_notFoundLabel                  ; target < arr[low]

        mov eax, target
        mov ebx, h
        imul ebx, 4
        cmp eax, [array + ebx]
        ja IS_notFoundLabel                  ; target > arr[high]

        ; calculate pos = low + ((target - arr[low]) * (high - low)) / (arr[high] - arr[low])
        mov eax, target
        mov ebx, l
        mov ecx, [array + ebx*4]            ; arr[low]
        sub eax, ecx                         ; eax = target - arr[low]

        mov ebx, h
        sub ebx, l                           ; ebx = high - low
        imul eax, ebx                         ; eax = (target - arr[low]) * (high - low)

        mov ebx, h
        mov ecx, l
        mov edx, [array + ebx*4]             ; arr[high]
        sub edx, [array + ecx*4]             ; edx = arr[high] - arr[low]

        ; divide eax by edx safely
        mov ebx, edx                          ; move divisor to EBX
        xor edx, edx                           ; clear EDX for division
        div ebx                                ; eax = ((target-arr[low])*(high-low))/(arr[high]-arr[low])

        add eax, l                             ; pos = low + result
        mov pos, eax

        ; compare arr[pos] with target
        mov eax, target
        mov ebx, pos
        imul ebx, 4
        cmp [array + ebx], eax
        je IS_foundLabel                      ; found

        ; if arr[pos] < target -> low = pos + 1
        mov eax, [array + ebx]
        cmp eax, target
        jl IS_moveLow

        ; else -> high = pos - 1
        mov eax, pos
        dec eax
        mov h, eax
        jmp IS_whileLoop

    IS_moveLow:
        mov eax, pos
        inc eax
        mov l, eax
        jmp IS_whileLoop

    IS_foundLabel:
        mov edx, offset found
        call writestring
        mov eax, pos
        call writedec
        call crlf
        ret

    IS_notFoundLabel:
        mov edx, offset notFound
        call writestring
        call crlf
        ret

InterpolationSearch endp


main proc

    mov edx, offset targetInput
    call writestring
    call readint
    mov target, eax

    ;Linear Search:
    call GetMseconds
    push eax                             ; push start time
    call LinearSearch
    call GetMseconds
    pop ebx                              ; pop start time into ebx
    sub eax, ebx

    mov edx, offset timeMsg
    call WriteString
    call WriteDec
    call Crlf


    ;Binary Search:
    call GetMseconds
    push eax                             ; push start time
    call BinarySearch
    call GetMseconds
    pop ebx                              ; pop start time into ebx
    sub eax, ebx

    mov edx, offset timeMsg
    call WriteString
    call WriteDec
    call Crlf


    ;Interpolation Search:

    call GetMseconds
    push eax                             ; push start time
    call InterpolationSearch
    call GetMseconds
    pop ebx                              ; pop start time into ebx
    sub eax, ebx

    mov edx, offset timeMsg
    call WriteString
    call WriteDec
    call Crlf

    exit
main endp

end main
