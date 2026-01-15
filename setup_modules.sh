#!/bin/bash

setup_vllm() {

    module purge
    module load Stages/2025
    module load GCC/13.3.0
    module load CUDA/12

    echo "======================================"
    echo "Node: $(hostname)"
    echo "CUDA: $(nvcc --version | grep release)"
    echo "GPUs:" 
    nvidia-smi --query-gpu=index,name,memory.total --format=csv,noheader
    echo "======================================"
    }

setup_vllm