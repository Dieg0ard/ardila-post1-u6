# lab6_instrucciones — Instrucciones y Direccionamiento x86 en NASM

**Autor:** Diego Ardila  
**Curso:** Arquitectura de Computadores — Ingeniería de Sistemas  
**Unidad:** 6 — Instrucciones y Direccionamiento  
**Actividad:** Post-Contenido 1  
**Año:** 2026

---

## Descripción

Este repositorio contiene el desarrollo del laboratorio de instrucciones mixtas en NASM para arquitectura x86. El programa (`lab6_instrucciones.asm`) es un ejecutable `.COM` de DOS que demuestra el uso práctico de las cuatro categorías fundamentales de instrucciones del procesador x86, compilado y ejecutado en DOSBox, con verificación de registros y flags mediante la herramienta DEBUG.

---

## Estructura del Repositorio

```
ardila-post1-u6/
├── lab6_instrucciones.asm     # Código fuente en NASM
├── lab6_instrucciones.com     # Binario compilado para DOS
├── README.md                  # Este archivo
└── capturas/
    ├── 01_compilacion.png     # Compilación exitosa en DOSBox
    ├── 02_debug_traza.png     # Trazado en DEBUG con flags
    └── 03_ax15_bucle.png      # Estado final AX=15 tras el bucle
```

---

## Requisitos del Entorno

| Software | Versión mínima |
|---|---|
| DOSBox | 0.74 |
| NASM (para DOS) | 2.11 |
| DEBUG.COM | Incluido en DOSBox o carpeta de herramientas |
| Editor de texto | Notepad++, VSCode + extensión ASM |

---

## Compilación y Ejecución

**Dentro de DOSBox:**

```dos
; 1. Montar la carpeta de trabajo
MOUNT C C:\Users\usuario\asm_lab6
C:

; 2. Compilar el programa
nasm -f bin lab6_instrucciones.asm -o lab6_instrucciones.com

; 3. Ejecutar directamente
lab6_instrucciones.com

; 4. Abrir con DEBUG para trazado
debug lab6_instrucciones.com
```

---

## Descripción de los Bloques del Programa

### Bloque 1 — Transferencia de Datos

Carga los valores definidos en memoria hacia los registros del procesador. Se demuestran las instrucciones `MOV` (copia directa de valor), `LEA` (carga de dirección de memoria), `XCHG` (intercambio entre registros) y el par `PUSH`/`POP` para preservar y restaurar valores en la pila.

| Instrucción | Operación | Resultado |
|---|---|---|
| `MOV ax, [valor_a]` | AX ← mem[valor_a] | AX = 45 |
| `MOV bx, [valor_b]` | BX ← mem[valor_b] | BX = 12 |
| `LEA si, [valor_a]` | SI ← dirección de valor_a | SI = offset |
| `XCHG cx, dx` | CX ↔ DX | intercambio |
| `PUSH ax / POP ax` | Guarda y restaura AX | AX = 45 |

> **Diferencia clave:** `MOV ax, [valor_a]` carga el *contenido* (45), mientras que `LEA si, [valor_a]` carga la *dirección* donde reside ese valor.

---

### Bloque 2 — Operaciones Aritméticas

Realiza suma, resta, incremento, decremento, multiplicación y división sobre los valores cargados. Se observa el efecto de cada operación sobre los flags del registro EFLAGS.

| Instrucción | Operación | Resultado | Flags relevantes |
|---|---|---|---|
| `ADD ax, [valor_b]` | AX = 45 + 12 | AX = 57 | ZF=0, CF=0, OF=0 |
| `SUB ax, [valor_a]` | AX = 12 − 45 | AX = −33 | SF=1, OF=0 |
| `INC ax` | AX = 45 + 1 | AX = 46 | No afecta CF |
| `DEC ax` | AX = 46 − 1 | AX = 45 | No afecta CF |
| `MUL bl` | AX = AL × BL = 10 × 7 | AX = 70 | — |
| `DIV bl` | AL = 100 ÷ 7, AH = resto | AL=14, AH=2 | — |

> **Nota:** `INC` y `DEC` no afectan el flag CF, a diferencia de `ADD` y `SUB`.

---

### Bloque 3 — Operaciones Lógicas

Manipula bits individuales usando las instrucciones `AND`, `OR`, `XOR`, `TEST`, `SHL` y `SHR`.

| Instrucción | Operación | Resultado |
|---|---|---|
| `AND al, [mascara]` | 0xB7 AND 0x0F | AL = 0x07 (conserva 4 bits bajos) |
| `OR al, 0F0h` | 0xB7 OR 0xF0 | AL = 0xF7 (activa 4 bits altos) |
| `XOR al, 0FFh` | NOT AL (0xAA) | AL = 0x55 (inversión completa) |
| `XOR bx, bx` | BX = 0 | Forma eficiente de limpiar registro |
| `TEST al, 01h` | AND sin guardar | ZF=0 → bit 0 activo (número impar) |
| `SHL al, 2` | AL = 8 << 2 | AL = 32 (×4) |
| `SHR al, 1` | AL = 32 >> 1 | AL = 16 (÷2) |

> **Diferencia clave entre AND y TEST:** `AND` modifica el operando destino; `TEST` solo actualiza los flags sin alterar el registro.

---

### Bloque 4 — Control de Flujo: Condicionales y Bucle

Implementa una estructura if/else con `CMP` y saltos condicionales (`JG`, `JE`, `JMP`), seguida de un bucle contado con `LOOP`.

**Estructura condicional:**
```
si valor_a > valor_b  →  CX = 1
si valor_a == valor_b →  CX = 2
si valor_a < valor_b  →  CX = 0
```
Con valor_a=45 y valor_b=12, el resultado es **CX = 1**.

**Bucle de suma acumulada (1 + 2 + 3 + 4 + 5):**

```nasm
XOR ax, ax          ; AX = 0 (acumulador)
MOV cx, 5           ; CX = contador
MOV bx, 1           ; BX = valor inicial
.bucle_suma:
    ADD ax, bx      ; AX += BX
    INC bx          ; siguiente valor
    LOOP .bucle_suma ; DEC CX; si CX≠0 → repetir
; Resultado final: AX = 15
```

---

## Variante: Factorial de 5 (Checkpoint 3)

El bucle de suma fue modificado para calcular **5! = 120**, reemplazando `ADD` por `MUL` y ajustando los valores iniciales:

```nasm
MOV ax, 1           ; AX = 1 (acumulador producto)
MOV cx, 5           ; CX = contador
MOV bx, 5           ; BX = valor inicial (5, 4, 3, 2, 1)
.bucle_factorial:
    MUL bx          ; AX = AX * BX
    DEC bx          ; BX-- (siguiente factor)
    LOOP .bucle_factorial
; Resultado: AX = 120
```

### LOOP vs DEC/JNZ — ¿Cuándo usar cada uno?

| Criterio | `LOOP etiqueta` | `DEC cx` + `JNZ etiqueta` |
|---|---|---|
| Registro contador | Siempre CX (fijo) | Cualquier registro |
| Tamaño | 1 instrucción compacta | 2 instrucciones |
| Flexibilidad | Limitado a CX | Cualquier registro de 16/32 bits |
| Afecta flags | No afecta flags | `DEC` sí afecta ZF, SF, OF |
| Cuándo preferirlo | Bucles simples donde CX está disponible | Cuando CX se necesita para otro propósito o se requiere mayor control sobre flags |

---

## Tabla de Registros y Flags Observados

| Instrucción | AX | BX | CX | ZF | CF | SF | OF |
|---|---|---|---|---|---|---|---|
| Tras `MOV ax, [valor_a]` | 45 | — | — | — | — | — | — |
| Tras `ADD ax, [valor_b]` | 57 | — | — | 0 | 0 | 0 | 0 |
| Tras `SUB ax, [valor_a]` (12−45) | −33 | — | — | 0 | 1 | 1 | 0 |
| Tras `AND al, [mascara]` | 0x07 | — | — | 0 | 0 | 0 | 0 |
| Tras `TEST al, 01h` | 0xB7* | — | — | 0 | 0 | — | — |
| Tras `CMP ax, [valor_b]` (45−12) | 45* | — | — | 0 | 0 | 0 | 0 |
| Tras bucle suma | 15 | 6 | 0 | 1 | 0 | 0 | 0 |

*El registro no se modifica.

---

## Commits del Repositorio

```
feat: estructura base del programa .COM y datos iniciales
feat: agregar bloque de transferencia de datos (MOV, LEA, XCHG, PUSH/POP)
feat: agregar bloque aritmético (ADD, SUB, INC, DEC, MUL, DIV)
feat: agregar bloque lógico (AND, OR, XOR, TEST, SHL, SHR)
feat: agregar control de flujo con condicionales y bucle LOOP
fix: corregir bucle factorial (variante Checkpoint 3)
docs: agregar README con descripción de bloques y tabla de flags
```

---

## Licencia

Actividad académica — Universidad Francisco de Paula Santander, 2026.
