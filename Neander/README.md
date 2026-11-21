# Processador Neander (INF1086 - Circuitos Digitais)

Implementação do processador didático **Neander** em Verilog HDL e esquemáticos do **Intel Quartus Prime**.

O Neander é uma máquina com arquitetura de von Neumann simplificada:
- Largura de dados: **8 bits**
- Largura de endereços: **8 bits** (espaço de memória de 256 bytes)
- Registradores:
  - **AC** (Acumulador): 8 bits
  - **PC** (Contador de Programa): 8 bits
  - **RI** (Registrador de Instrução): 8 bits (4 bits mais significativos para o opcode)
  - **REM** (Registrador de Endereço da Memória): 8 bits
  - **RDM** (Registrador de Dados da Memória): 8 bits
  - **Flags**: `N` (Negativo) e `Z` (Zero)

---

## Estrutura do Diretório

```plaintext
Neander/
├── rtl/                        # Código Verilog dos módulos sintetizáveis
│   ├── codificador_neander.v   # Codificador para controle da ULA
│   ├── conversor_bcd.v         # Conversor binário para BCD (displays 7 segmentos)
│   ├── decoder_4x11.v          # Decodificador de instruções (opcode -> sinais de operação)
│   ├── divisor_frequencia.v    # Divisor de clock para operação em placa FPGA
│   ├── ff_d.v                  # Flip-Flop Tipo D (usado para flags e registradores)
│   ├── pc_estrutural.v         # Contador de Programa com lógica de incremento e carga
│   ├── temporizador.v          # Gerador de ciclos de temporização (estados t0..t7)
│   ├── ula.v                   # Unidade Lógica e Aritmética (ADD, AND, OR, NOT, Y)
│   └── unidade_controle.v      # Unidade de Controle com máquina de estados microoperacional
│
├── schematics/                 # Esquemáticos e símbolos de bloco do Quartus Prime
│   ├── neander_top.bdf         # Esquemático Top-Level do Neander
│   └── symbols/                # Símbolos gerados (.bsf) para esquemáticos
│       ├── conversor_bcd.bsf
│       ├── decoder_4x11.bsf
│       ├── divisor_frequencia.bsf
│       ├── ff_d.bsf
│       └── ula.bsf
│
├── sim/                        # Bancos de teste e arquivos de simulação
│   ├── tb_unidade_controle.v   # Testbench abrangente da Unidade de Controle
│   ├── run_sim.sh              # Script para compilação e simulação via Icarus Verilog
│   └── waveforms/              # Arquivos de formas de onda do Quartus
│       └── opcode.vwf
│
├── docs/                       # Apostilas e documentação de referência
│   └── Neander - Organização - Part. 2.pdf
│
├── neander.qpf                 # Projeto Intel Quartus Prime
├── neander.qsf                 # Configurações e lista de arquivos de compilação
└── README.md                   # Esta documentação
```

---

## Conjunto de Instruções (ISA)

| Mnemônico | Opcode (Binário) | Hex | Descrição |
| :---: | :---: | :---: | :--- |
| **NOP** | `0000` | `0` | Nenhuma operação |
| **STA** | `0001` | `1` | Armazena acumulador no endereço especificado: `MEM[end] <- AC` |
| **LDA** | `0010` | `2` | Carrega acumulador com conteúdo da memória: `AC <- MEM[end]` |
| **ADD** | `0011` | `3` | Soma acumulador com memória: `AC <- AC + MEM[end]` |
| **OR**  | `0100` | `4` | Operação lógica OU: `AC <- AC \| MEM[end]` |
| **AND** | `0101` | `5` | Operação lógica E: `AC <- AC & MEM[end]` |
| **NOT** | `0110` | `6` | Inverte os bits do acumulador: `AC <- ~AC` |
| **JMP** | `1000` | `8` | Desvio incondicional: `PC <- end` |
| **JN**  | `1001` | `9` | Desvio se negativo: `Se N=1, PC <- end` |
| **JZ**  | `1010` | `A` | Desvio se zero: `Se Z=1, PC <- end` |
| **HLT** | `1111` | `F` | Para a execução do processador |

---

## Simulação via Terminal (Icarus Verilog + GTKWave)

O projeto pode ser simulado de forma rápida sem abrir o Quartus.

### Executar a simulação da Unidade de Controle:
```bash
cd Neander/sim
./run_sim.sh
```

### Visualizar as formas de onda:
Após rodar o script, visualize o arquivo de dump gerado:
```bash
gtkwave unidade_controle.vcd
```

---

## Compilação no Intel Quartus Prime

1. Abra o arquivo de projeto `neander.qpf` no **Quartus Prime Lite Edition**.
2. Para definir a entidade que deseja sintetizar ou testar:
   - No menu: **Assignments** > **Settings** > **General** > **Top-level entity**.
   - Para compilar a Unidade de Controle: `unidade_controle`.
   - Para compilar o esquemático integrado: `neander_top`.
3. Inicie a compilação: **Processing** > **Start Compilation** (ou `Ctrl + L`).

## Operação na Placa DE0 (Cyclone III EP3C16F484C6)

O projeto `neander_top` roda na placa **Terasic DE0**. Esta seção descreve o que cada entrada e saída representa e o que acontece ao interagir com a placa.

---

### Entradas

| Sinal no esquemático | Componente da placa | Pino | Função |
| :--- | :--- | :---: | :--- |
| `clk_global` | `CLOCK_50` | `PIN_G21` | Clock de 50 MHz, entrada do divisor de frequência. |
| `rstn` | `BUTTON0` | `PIN_H2` | **Reset** assíncrono, ativo em nível baixo (0). |
| `btn_step` | `BUTTON1` | `PIN_G3` | **Step**: dá um passo de clock no modo DEBUG. |
| `sw_run_debug` | `SW0` | `PIN_J6` | Seleciona o modo **RUN** ou **DEBUG**. |

Os botões da DE0 entregam nível **alto (1) quando soltos** e nível **baixo (0) quando apertados**. Por isso o reset do projeto é ativo em 0: apertar o `BUTTON0` ativa o reset, e soltar o desativa.

---

### Saídas

| Saída | Componente da placa | O que mostra |
| :--- | :--- | :--- |
| `out_pc[7..0]` | Dois displays de 7 segmentos da esquerda | Valor do **PC** em hexadecimal. |
| `out_acm[7..0]` | Dois displays de 7 segmentos da direita | Valor do **AC** em hexadecimal. |
| Flag **N** | `LEDG0` | Aceso quando o último resultado da ULA foi negativo. |
| Flag **Z** | `LEDG1` | Aceso quando o último resultado da ULA foi zero. |
| `hlt` | `LEDG5` | Aceso quando o processador executou **HLT** e parou. |

---

### Modos de operação (`SW0`)

O circuito `run_step_mode` escolhe qual sinal vira o **clock efetivo** do processador:

| Posição do `SW0` | Valor | Modo | Clock do processador |
| :---: | :---: | :---: | :--- |
| **Para baixo** (perto da borda da placa) | `0` | **RUN** | Clock do divisor, ≈ 3 Hz, contínuo. |
| **Para cima** | `1` | **DEBUG** | Um ciclo de clock a cada clique no `BUTTON1`. |

- **RUN:** o processador executa sozinho, de forma lenta o bastante para acompanhar os displays. O divisor de frequência gera ≈ 3 Hz (50 MHz / 2²⁴ ≈ 2,98 Hz), ou seja, um ciclo de clock a cada ≈ 0,34 s.
- **DEBUG:** o clock fica parado. Cada vez que o `BUTTON1` é apertado, o processador avança **exatamente um ciclo de clock** (um passo de temporização, t0, t1, ...). Ao soltar o botão, nada acontece. Um clique **não** executa uma instrução inteira, e sim um passo dela.

> **Dica:** ao trocar de modo, pode ocorrer um passo extra de clock. Se quiser um estado limpo, aperte o reset (`BUTTON0`) depois de mudar o `SW0`.

---

### O que acontece ao apertar cada botão

#### `BUTTON0` (reset)
- **Segurando:** o reset está ativo. É assíncrono, então atua imediatamente, sem esperar o clock. O PC, o contador de temporização, os registradores e as flags são zerados, e o divisor de frequência também. Os displays mostram `00` e o clock é ignorado.
- **Ao soltar:** o reset é desativado e o processador começa a executar a partir do endereço `00` (PC = 0).

#### `BUTTON1` (step)
- Só tem efeito no **modo DEBUG**. No modo RUN ele é ignorado.
- **Ao apertar:** o clock efetivo sobe de 0 para 1, e todos os registradores capturam o seu valor. Isso avança um passo da instrução em andamento.
- **Ao soltar:** o clock efetivo desce e nada é capturado.

#### `SW0` (modo)
- É uma chave, não um botão. A posição escolhe o modo e não gera nenhum passo por si só.

---

### Duração de cada instrução (em ciclos de clock)

Cada instrução passa por passos de temporização (`t0`, `t1`, ...). No modo DEBUG, cada clique avança um passo.

| Instrução | Passos | Ciclos |
| :--- | :---: | :---: |
| **STA, LDA, ADD, OR, AND** | t0 a t7 | 8 |
| **NOT** | t0 a t3 | 4 |
| **NOP** | t0 a t3 | 4 |
| **JMP** | t0 a t5 | 6 |
| **JN** com N = 1, **JZ** com Z = 1 (desvio tomado) | t0 a t5 | 6 |
| **JN** com N = 0, **JZ** com Z = 0 (desvio não tomado) | t0 a t3 | 4 |
| **HLT** | para em t3 | — |

Os passos t0 a t2 são a **busca da instrução** (o PC é lido, a instrução vai para o RI e o PC é incrementado). Os passos seguintes dependem da instrução.

No modo RUN, uma instrução de 8 ciclos leva ≈ 2,7 s.

---

### Parada do processador (HLT)

Ao executar **HLT** (`1111`), o temporizador congela em `t3` e o processador pára: o PC deixa de mudar e o `LEDG5` acende. Para executar de novo, aperte o **reset** (`BUTTON0`).

---

### Como usar passo a passo

1. Compile o projeto (**Processing > Start Compilation**) e programe a placa (**Tools > Programmer**).
2. Coloque o `SW0` em **DEBUG** (para cima) para acompanhar passo a passo, ou em **RUN** (para baixo) para executar sozinho.
3. Aperte e solte o `BUTTON0` para resetar. O PC e o AC mostram `00`.
4. No modo **DEBUG**, aperte o `BUTTON1` para avançar um ciclo por vez e observe o PC, o AC e as flags N e Z. No modo **RUN**, apenas observe a execução.
5. Quando o `LEDG5` acender, o programa terminou com HLT.

---

### Observações

- Os botões da DE0 têm circuito de debounce em hardware apenas na versão de placa **PCB 10-0100730-A0**. Se o `BUTTON1` gerar mais de um passo por clique, a sua placa pode ser de outra versão.
- As chaves deslizantes **não** têm debounce. Troque o `SW0` com o processador parado, de preferência.
- O reset de todos os módulos usa a mesma polaridade: **ativo em 0** (`rstn`).