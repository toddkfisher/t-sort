section .bss

        ; Two parallel arrays:
        ; - indeg[i] == indegree of node i
        ; - ignore_node[i] == node i was found to be a root.  Do not consider it
        ;   any longer.
        ; 0 is not a valid node number since it is used as a sentinel in the edge list.
        INDEG resb 256
        IGNORE_NODE resb 256

section .text

global t_sort
;; bool t_sort(
;;              rdi : EDGE *p_edge_list,
;;              rsi : uint8_t *p_sorted_list,
;;              rdx : uint8_t n_nodes
;;            )
;; Locals
;; rcx : loop counter
;; r8  : pointer to edge list entry
;; r9  : "from" node
;; r10 : "to" node
;; r11 : "ignore node" flag
;; r12 : index into sorted list of nodes.
;; r13 : indegree of rcx

;; Sort algorithm:
;;
;; 1. Find a node with indeg == 0,
;; 3->2. If no node could be found with indeg == 0, and graph not empty then exit with  failure (cycle found).
;; 4->3. Otherwise:
;;   4.1->3.1 Place node on sorted list.
;;            If size of sorted list == n_nodes, then exit with success.
;;   4.2->3.2 Remove node from graph.
;;   4.3->3.3 Decrement indegree of all nodes which are children.
;; 5->4. Go back to step 1

;; Restrictions:
;; A. Number of nodes (rdx) must fall between 0 and 254.  255 is used as a sentinel in the edge list (rdi).
;; B. Node numbers (n) must fall between 0 and rdx - 1
;; C. 0 .. (rdx - 1) must be part of the graph.

t_sort:
        cmp dl, 0
        je .exit_with_success                ; Graph empty -> nothing to sort.
        ; Initialize both parallel array to zeroes (loop0)
        mov r8, rdi
        mov rcx, 0
.loop0:
        cmp rcx, rdx
        jge .exitloop0
        mov byte [INDEG + rcx], 0
        mov byte [IGNORE_NODE + rcx], 0
        inc rcx
        jmp .loop0
.exitloop0:
        ; Calculate initial indegree for each node (loop1)
        mov r8, rdi                          ; Loop thru edge_list.
.loop1:
        movzx r9, byte [r8]                  ; Get "from" field.
        movzx r10, byte [r8 + 1]             ; Get "to" field.
        cmp r9, 0xff                         ; 0xff, 0xff entry is an "end of list" sentinel.
        je .endloop1
        movzx r15, byte [INDEG + r10]        ; Get indeg of "to" node and increment it.
        inc r15
        mov byte [INDEG + r10], r15b
        add r8, 2                            ; Next edge.
        jmp .loop1
.endloop1:
        mov r12, 0                           ; Nothing sorted yet.
;; Step 1. Find a node with indeg == 0 (loop2)
.loop1_2:
        mov  rcx, 0
.loop2:
        cmp rcx, rdx
        jge .endloop2_0
        movzx r11, byte [IGNORE_NODE + rcx]  ; Check that node rcx is part of the graph.
        cmp r11, 1
        je .jump0                            ; Node is not part of the graph, try next node.
        movzx r13, byte [INDEG + rcx]        ; Check if node rcx has indeg == 0.
        cmp r13, 0
        jne .jump0                           ; No, try next node.
        jmp .endloop2_1                      ; Node is part of the graph and has indeg == 0. Proceed to step 4.
.jump0:
        inc rcx
        jmp .loop2
.endloop2_0:
        ; If we reach this point, then we've gone thru the entire list and have not found a node
        ; ... with indeg == 0 so we must have a loop.
        jge .exit_with_failure
.endloop2_1:
;; Step 3.1 (place node on sorted list and check size of sorted list).
        mov byte [rsi + r12], cl
        inc r12
        cmp r12, rdx
        jge .exit_with_success
;; Step 3.2 Remove node from graph. (by flagging it to be ignored)
        mov byte [IGNORE_NODE + rcx], 1
;; Step 3.3 Decrement indegree of all nodes which are children of rcx. (loop3)
        mov r8, rdi                          ; Loop thru edge_list
.loop3:
        movzx r9, byte [r8]                  ; Get "from" node in edge list.
        cmp r9, 0xff                         ; Have we reached the end of list sentinel?
        je .endloop3                         ; Yes -- end of step 4.3.
        cmp r9, rcx                          ; Does this edge start at rcx?
        jne .jump1                           ; No try next.
        movzx r10, byte [r8 + 1]             ; Yes, get "to" node.
        movzx r15, byte [INDEG + r10]        ; Get indegree of "to" node and decrement.
        dec r15
        mov byte [INDEG + r10], r15b         ; ... and save back into INDEG array.
.jump1:
        add r8, 2                            ; Examine next item in edge array.
        jmp .loop3
.endloop3:
;; Step 4. Go back to step 1.
        jmp .loop1_2
.exit_with_success:
        mov rax, 1
        ret
.exit_with_failure:
        mov rax, 0
        ret
