#!/usr/bin/env bash

# run this with sudo

conda_dir=${conda_dir:-/opt/conda}

while [ $# -gt 0 ]; do
   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
        # echo $1 $2 // Optional to see the parameter:value result
   fi
  shift
done

wget -nv https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O Miniconda.sh && \
	/bin/bash Miniconda.sh -f -b -p ${conda_dir} && \
	rm Miniconda.sh && \
  PATH=${conda_dir}/bin:$PATH && \
  #source $(conda info --base)/etc/profile.d/conda.sh && \
  conda init
