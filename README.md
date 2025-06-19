<!-- README.md -->

# 🦙 LANTA Ollama WebSocket Streamer

A real-time text-streaming service using [Ollama](https://ollama.com), FastAPI, and WebSockets on LANTA Thailand's Supercomputer.
Users can send prompts from a simple HTML front-end and see the model’s response appear letter-by-letter.

---

## 📂 Repository Structure

```
.
├── stream.py               # WSConnectionManager + OllamaClient
├── main.py                 # FastAPI WebSocket endpoint
├── pages/
│   └── ws_client.html      # Simple HTML/JS WebSocket front-end
├── run_fastapi_ollama.slurm  # SLURM job submission script
└── README.md
```

---

## ⚙️ Prerequisites

* Python 3.8+
* [`ollama`](https://ollama.com) binary v0.5.7 (or later) installed
* A model downloaded under your `OLLAMA_MODELS` directory (e.g. `qwen3:14b`)
* FastAPI & Uvicorn (`pip install fastapi uvicorn aiohttp loguru`)
* Access to an HPC cluster (optional) with SLURM and Mamba/Conda

---

## 🔧 Configuration

Before running, **you must** set the following environment variables to match your local or cluster setup:

```bash
# Where ollama’s HTTP API will listen (host:port)
export OLLAMA_HOST=0.0.0.0:11434

# Directory where ollama keeps its downloaded models
export OLLAMA_MODELS=/path/to/your/OLLAMA/models

# (Optional) A scratch directory on your cluster
export SCRATCH_BASE=/scratch/shared/$USER

# The model tag you wish to serve (must exist under $OLLAMA_MODELS)
export OLLAMA_MODEL=qwen3:14b

# Add Ollama’s native libraries to the linker path
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/path/to/OLLAMA/lib

# Add Ollama’s binaries to your PATH
export PATH=${PATH}:/path/to/OLLAMA/bin
```

> **💡 Tip:** If you installed Ollama under `~/ollama`, you might set:
>
> ```bash
> export OLLAMA_HOST=127.0.0.1:11434
> export OLLAMA_MODELS=~/ollama/models
> export LD_LIBRARY_PATH=~/ollama/lib:${LD_LIBRARY_PATH}
> export PATH=~/ollama/bin:${PATH}
> ```

---

## ▶️ Running Locally

1. **Start Ollama**

   ```bash
   ollama serve &
   ```

2. **Run FastAPI**

   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8000
   ```

3. **Open the client**
   Navigate your browser to `http://localhost:8000/pages/` (or `/pages/ws_client.html`).

---

## 📡 Submitting on SLURM

We've provided `run_fastapi_ollama.slurm` for HPC environments:

```bash
sbatch run_fastapi_ollama.slurm
```

Inside that script:

1. Loads Mamba and activates `fastapi` env.
2. Exports:

   * `port` (e.g. `8000` for Uvicorn)
   * `OLLAMA_HOST`, `OLLAMA_MODELS`, `SCRATCH_BASE`, `OLLAMA_MODEL`, `LD_LIBRARY_PATH`, `PATH`
3. Starts `ollama serve &` and waits 10 s.
4. Prints an `ssh -L ${port}:${node}:${port}` command for port forwarding from your laptop.
5. Launches `uvicorn main:app --host 0.0.0.0 --port ${port}`.

> **Note:** Edit the top of the SLURM script to match your account, partition, and desired model paths.

---

## 📝 Usage Flow

1. **Browser** opens a WebSocket to `/generate/text/streams`.
2. **WSConnectionManager** accepts and tracks each connection.
3. User types a prompt and hits “Start Streaming.”
4. **FastAPI** receives the prompt, passes it to **OllamaClient**.
5. **Ollama** streams JSON-encoded chunks back.
6. Each chunk is forwarded instantly over WebSocket.
7. **Client** appends text piece-by-piece to produce a “typing” effect.

---

## 🚀 Do It Yourself

1. Clone this repo.
2. Install Python deps and Ollama.
3. Configure your environment variables as shown above.
4. Run `ollama serve &` then `uvicorn main:app ...`.
5. Open the HTML front-end, send a prompt, and enjoy real-time AI streaming!

---

## 📄 License

MIT © Sakchai Saehoei / NECTEC 2025
