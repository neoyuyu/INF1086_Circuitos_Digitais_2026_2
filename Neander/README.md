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
