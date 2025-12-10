# e155/scripts

**Useful scripts for routine tasks with local ollama and dockerized OpenWebUI**

A small collection of shell scripts that help automate repetitive actions in Unix/Linux environments.

---

## 🧰 What's in the repository

| Script name   | Short description |
|---------------|--------------------|
| `shmod.sh`    | — show Ollama installed models details |
| `updmod.sh`   | — update Ollama installed models |
| `updowu.sh`   | — updates docker OpenWebUI image |
| `upollama.sh` | — updates local Ollama |

---
## shmod.sh

This script lists all locally installed Ollama models and prints key parameters for each one:

- **Model name**
- **Context length**
- **Embedding length**
- **Quantization type**
  
#### Example

```bash
~$ ./shmod.sh
Model                                    Context Length  Embedding Length   Quantization
-----                                    -------------   ---------------    -----------
gpt-oss:20b                              131072          2880               MXFP4
qwen2.5:32b                              32768           5120               Q4_K_M
bge-m3:latest                            8192            1024               F16
qwen3-vl:4b                              262144          2560               Q4_K_M
```

## How to use

1. Clone the repository  
   ```bash
   git clone https://github.com/e155/scripts.git
