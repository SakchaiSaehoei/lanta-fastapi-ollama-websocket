#!/bin/bash

# ——————————————————————————————
# 📌 User Configuration: SBATCH directives (edit these)
# ——————————————————————————————
#SBATCH -p <YOUR_PARTITION>                   # e.g. gpu, cpu, etc.
#SBATCH -N <NUM_NODES> -c <CPUS_PER_NODE>     # e.g. 1 node, 32 cores
#SBATCH --gpus-per-node=<GPUS_PER_NODE>       # e.g. 4
#SBATCH --ntasks-per-node=<TASKS_PER_NODE>    # e.g. 1
#SBATCH -t <WALLTIME>                         # format HH:MM:SS, e.g. 02:00:00
#SBATCH -A <YOUR_ACCOUNT>                     # your SLURM project/account
#SBATCH -J <YOUR_JOB_NAME>                    # e.g. fastapi_ollama
# ——————————————————————————————
# End of SBATCH configuration
# ——————————————————————————————

ml Mamba
mamba activate fastapi

# ——————————————————————————————
# 📌 User Configuration: Environment variables (edit these)
# ——————————————————————————————
export port=<YOUR_UVICORN_PORT>                       # e.g. 8000
export USER=$(whoami)                                 # your cluster username
export node=$(hostname -s)                            # compute node hostname

export OLLAMA_HOST="<YOUR_HOST>:<OLLAMA_PORT>"        # e.g. 127.0.0.1:11434
export OLLAMA_MODELS="<PATH_TO_OLLAMA_MODELS>"        # e.g. /home/$USER/ollama/models
export SCRATCH_BASE="<YOUR_SCRATCH_BASE_DIR>"         # optional scratch directory
export OLLAMA_MODEL="<YOUR_MODEL_TAG>"                # e.g. qwen3:14b

export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:<OLLAMA_LIB_PATH>"  # e.g. /home/$USER/ollama/lib
export PATH="<OLLAMA_BIN_PATH>:${PATH}"                        # e.g. /home/$USER/ollama/bin
# ——————————————————————————————
# End of environment configuration
# ——————————————————————————————

echo "==============================================="
echo "Assigned port:        ${port}"
echo "User:                 ${USER}"
echo "Node:                 ${node}"
echo "OLLAMA_HOST:          ${OLLAMA_HOST}"
echo "OLLAMA_MODELS:        ${OLLAMA_MODELS}"
echo "OLLAMA_MODEL:         ${OLLAMA_MODEL}"
echo "LD_LIBRARY_PATH:      ${LD_LIBRARY_PATH}"
echo "PATH:                 ${PATH}"
echo "==============================================="

# Start Ollama server in the background
ollama serve &

# Give Ollama time to initialize
sleep 10

# ——————————————————————————————
# 🚀 SSH Port‐Forwarding Hint (visible highlight)
# ——————————————————————————————
echo
echo "==============================================="
echo -e "\e[1;33m🚀 To forward the port back to your laptop, run:\e[0m"
echo -e "    \e[1;32mssh -L ${port}:${node}:${port} ${USER}@lanta.nstda.or.th -i <path_to_your_key>\e[0m"
echo "==============================================="
echo

# Launch FastAPI WebSocket service
uvicorn main:app --host 0.0.0.0 --port ${port}

# Prevent the script from exiting immediately
sleep 15


