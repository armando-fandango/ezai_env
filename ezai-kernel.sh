#!/usr/bin/env bash

conda activate ezai || source activate ezai
# Expose environment as kernel
python -m ipykernel install --user --name ezai --display-name "ezai"
conda deactivate || source deactivate
