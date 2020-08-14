#!/usr/bin/env bash

# run this with sudo

CONDA_DIR=/opt/conda

wget -nv https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O Miniconda.sh && \
	/bin/bash Miniconda.sh -f -b -p $CONDA_DIR && \
	rm Miniconda.sh && \
  PATH=${CONDA_DIR}/bin:$PATH && \
  #source $(conda info --base)/etc/profile.d/conda.sh && \
  conda init
