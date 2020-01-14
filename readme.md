# RISC-V CPU

518030910431 唐泽

```
Brevity is the soul of wit.
```

It's a simple RISC-V CPU with 5-stage pipeline.

## Main Ideal

### FORWARDING

To solve RAW hazard, EX & MEM send the updated data to ID.

### MEM_CTRL

MEM_CTRL is born to avoid conflict between IF & MEM memory access.  

It is designed to be sequential circuit.

### STALL_CTRL

STALL_CTRL is designed to stall pipeline when IF or MEM accessing memory.

For the instantaneity of stall, STALL_CTRL is designed to be combination circuit.

### BRANCH PREDICTION

To reduce stall, we predict branch not taken, and take the next instruction immediately.  Whether to branch is determined in ID. In the case of branch taken, a jump signal is sent to IF in a gesture to change PC request.

## Details

- Since the whole pipeline will stall when memory access request sent from MEM, my MEM_CTRL is designed that MEM request can interrupt IF request, and thus we will suffer from less stalls.
- In the case of branch, MEM_CTRL is setting about processing the first fetch when we realize we need to branch. It's stupid to wait more cycles for a wrong instruction, and thus MEM_CTRL takes more responsibility to be interrupted when branch and restart fetching the right instruction.

## Obstacles 

- Design of MEM_CTRL and STALL_CTRL have been reconstructed several times.
- I'm a master of bug.