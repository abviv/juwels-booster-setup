# vLLM Development Setup on HPC Juwels Booster/Cluster

This guide walks through setting up a vLLM development environment on an HPC Juwels cluster using SLURM for job allocation.

## Prerequisites

- Access to the cluster with appropriate project account
- Basic familiarity with SLURM commands
- Python 3.10+

## Step 1: Request Compute Resources

### For Single Node Development (4 GPUs)

```bash
salloc --partition=booster --nodes=1 --ntasks-per-node=1 --gres=gpu:4 --time=02:00:00 --account=<your-project>
```

### For Multi-Node Distributed Testing (8 GPUs across 2 nodes)

```bash
salloc --partition=booster --nodes=2 --ntasks-per-node=1 --gres=gpu:4 --time=02:00:00 --account=<your-project>
```

**Note:** Replace `<your-project>` with your actual project account name.

## Step 2: Start Interactive Session with tmux

Once your allocation is granted, start a tmux session for better session management:

```bash
tmux new -s vllm-profile
```

Then, within the tmux session, start an interactive bash session on the compute node:

```bash
srun --pty bash
```

**Why tmux?** Using tmux allows you to:
- Detach from the session without losing your work (`Ctrl+b`, then `d`)
- Resume the session later with `tmux attach -t vllm-profile`
- Keep processes running even if you disconnect

⚠️ **Important:** Closing the terminal window that started the `srun` command will terminate your allocation and release the compute resources. Use tmux to detach safely instead.

### Quick tmux Reference

- **Detach from session:** `Ctrl+b`, then press `d`
- **Reattach to session:** `tmux attach -t vllm-profile`
- **List sessions:** `tmux ls`
- **Kill session:** `tmux kill-session -t vllm-profile`

## Step 3: Setup Environment Modules

Load the required CUDA modules by running your setup script:
remember to do the `chmod u+x on the .sh`

```bash
./setup_modules.sh
```

**Expected behavior:** This may throw an error initially, but it will properly load the necessary CUDA modules.

## Step 4: Install UV Package Manager

Since compute nodes typically don't have internet access, you'll need to set up UV from the login node first.

### On Login Node

Navigate to your project directory and create a virtual environment:

```bash
cd $PROJECT/vllm-dev/
uv venv --python 3.12 vllm-env
```

Activate the environment:

```bash
source vllm-env/bin/activate
```

Install vLLM (this may take several minutes):

```bash
uv pip install vllm --torch-backend=auto
```

## Step 5: Verify Installation on Compute Node

Switch back to your terminal connected to the compute node and verify CUDA availability:

### Quick Check

```bash
python -c "import torch; print(torch.cuda.is_available())"
```

Expected output: `True`

### Check GPU Count

```python
import torch

# Get total number of GPUs visible to current process
num_gpus = torch.cuda.device_count()
print(f"Number of GPUs available: {num_gpus}")
```

Expected output: `Number of GPUs available: 4` (or 8 for multi-node setup)

## Common Issues

- **No internet on compute nodes:** Always install packages from the login node before switching to compute nodes
- **CUDA not found:** Ensure `setup_modules.sh` ran successfully and check loaded modules with `module list`
- **Environment not activated:** Remember to activate the virtual environment on both login and compute nodes

## Directory Structure

```
$PROJECT/vllm-dev/
├── vllm-env/           # Virtual environment
├── setup_modules.sh    # CUDA module setup script
└── README.md           # This file
```

## Next Steps

After successful setup, you can:
- Run vLLM inference examples
- Profile model performance across multiple GPUs
- Test distributed serving configurations

---

**Tip:** For longer development sessions, request more time in your `salloc` command (e.g., `--time=08:00:00` for 8 hours).