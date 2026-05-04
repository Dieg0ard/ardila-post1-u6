; lab6_instrucciones.asm — Demostración de categorías de instrucciones x86
; Compilar: nasm -f bin lab6_instrucciones.asm -o lab6_instrucciones.com
org 100h ; offset de inicio para archivos .COM
; ── Datos
jmp inicio ; saltar sobre los datos al código
valor_a dw 45 ; primer operando
valor_b dw 12 ; segundo operando
resultado dw 0 ; almacena resultado
contador db 5 ; contador de bucle
mascara db 0Fh ; máscara de 4 bits bajos
; ── Código
inicio:
; ── BLOQUE 1: Transferencia de datos
 ; MOV: carga valor de memoria a registro
 MOV ax, [valor_a] ; AX = 45 (contenido de valor_a)
 MOV bx, [valor_b] ; BX = 12 (contenido de valor_b)
 ; MOV entre registros
 MOV cx, ax ; CX = AX = 45
 MOV dx, bx ; DX = BX = 12
 ; LEA: carga la dirección, no el contenido
 LEA si, [valor_a] ; SI = dirección de valor_a (no su valor)
 MOV ax, [si] ; AX = mem[SI] = 45 (indirecto vía SI)
 ; XCHG: intercambio de registros
 XCHG cx, dx ; CX=12, DX=45
 XCHG cx, dx ; restaurar: CX=45, DX=12
 ; PUSH/POP: preservar y restaurar
 PUSH ax ; guarda AX=45 en pila
 MOV ax, 0FFFFh ; modifica AX temporalmente
 POP ax 
 ; ── BLOQUE 2: Operaciones aritméticas
 ; ADD: suma con actualización de flags
 MOV ax, [valor_a] ; AX = 45
 ADD ax, [valor_b] ; AX = 45 + 12 = 57 (ZF=0, CF=0, OF=0)
 MOV [resultado], ax ; guarda 57 en memoria
 ; SUB: resta
 MOV ax, [valor_b] ; AX = 12
 SUB ax, [valor_a] ; AX = 12 - 45 = -33 (SF=1, OF=0)
 ; INC y DEC: incremento/decremento (no afectan CF)
 MOV ax, [valor_a] ; AX = 45
 INC ax ; AX = 46
 DEC ax ; AX = 45
 ; MUL: multiplicación sin signo (AX = AL * operando)
 MOV al, 10 ; AL = 10
 MOV bl, 7 ; BL = 7
 MUL bl ; AX = AL * BL = 70; DX contiene parte alta
 ; División: AX / operando → AL=cociente, AH=resto
 MOV ax, 100 ; AX = 100
 MOV bl, 7 ; BL = 7
 DIV bl ; AL = 14, AH = 2 (100 = 7*14 + 2)
 ; ── BLOQUE 3: Operaciones lógicas
 MOV al, 0B7h ; AL = 1011 0111b = 0xB7
 ; AND: máscara de limpieza — conserva solo los 4 bits bajos
 AND al, [mascara] ; AL = 0B7h AND 0Fh = 0111b = 07h
 MOV al, 0B7h ; restaurar AL
 ; OR: activar bits — activa los 4 bits altos
 OR al, 0F0h ; AL = 0B7h OR F0h = 1111 0111b = F7h
 MOV al, 0AAh ; AL = 1010 1010b
 ; XOR: inversión selectiva
 XOR al, 0FFh ; AL = NOT AL = 0101 0101b = 55h
 ; XOR reg,reg: forma estándar de poner a cero un registro (1 byte < MOV)
 XOR bx, bx ; BX = 0 (más eficiente que MOV bx,0)
 ; TEST: AND sin guardar resultado — solo actualiza flags
 MOV al, 0B7h
 TEST al, 01h ; ZF=0 si bit 0 = 1 (número impar)
 ; El resultado no se guarda, AL sigue siendo 0B7h
 ; SHL/SHR: desplazamiento = multiplicar/dividir por 2
 MOV al, 08h ; AL = 8
 SHL al, 2 ; AL = 8 << 2 = 32 = 0x20
 SHR al, 1 ; AL = 32 >> 1 = 16 = 0x10
 ; ── BLOQUE 4: Control de flujo
 ; Estructura if/else: comparar valor_a con valor_b
 MOV ax, [valor_a] ; AX = 45
 CMP ax, [valor_b] ; AX - valor_b = 45 - 12 = 33 > 0
 JG .mayor ; salta si AX > valor_b (con signo)
 JE .igual ; salta si AX == valor_b
 ; AX < valor_b — caso menor (no se alcanza en este programa)
 XOR cx, cx ; CX = 0 como indicador
 JMP .fin_cmp
.mayor:
 MOV cx, 1 ; CX = 1: indica que valor_a > valor_b
 JMP .fin_cmp
.igual:
 MOV cx, 2 ; CX = 2: indica igualdad
.fin_cmp:
 ; Bucle: suma acumulada de 1 a 5 (resultado esperado: 15)
 MOV ax, 1       ; AX = 1 (acumulador, no 0 porque multiplicamos)
 MOV cx, 5       ; contador
 MOV bx, 1       ; valor inicial
 .bucle_factorial:
    MUL bx      ; AX = AX * BX
    INC bx
    LOOP .bucle_factorial
 ; AX = 120 (5! = 1*2*3*4*5)
 ; Fin del programa
 INT 20h ; retornar a DOS
 