#!/usr/bin/env pwsh
param ($venv='c:/Miniconda3/envs/ezai', $py_ver='3.8', $piptxt='./ezai-pip-req.txt', $condatxt='./ezai-conda-req.txt')

#TODO: probably change venv default to ~/envs once docker is implemented
# conda_base=$(conda info --base)
# add conda_base to venv

# add -k if ssl_verify needs to be set to false

function ProceedOrExit {
    if ($?) { echo "Proceed.." } else { echo "Script FAILED! Exiting.."; exit 1 }
}

Write-Host "setting base conda to 4.6.14"
conda activate base
conda config --env --set auto_update_conda False
conda config --show-sources
conda install -y --no-update-deps "conda=4.6.14" "python=3.7.9"
conda deactivate

Write-Host "creating $venv with python $py_ver ..."
echo "conda create -y -p $venv -c conda-forge python=$py_ver"
conda create -y -p $venv -c conda-forge "python=$py_ver"

conda activate $venv
conda config --env --append channels conda-forge
conda config --env --set auto_update_conda False
conda config --env --remove channels defaults

#conda install -y -S -p $venv -c conda-forge "ipython>7.0" "notebook>=6.0.0" jupyter_contrib_nbextensions jupyter_nbextensions_configurator yapf ipywidgets
#jupyter nbextension enable --user code_prettify/code_prettify
#jupyter nbextension enable --user toc2/main
#jupyter nbextension enable --user varInspector/main
#jupyter nbextension enable --user execute_time/ExecuteTime
#jupyter nbextension enable --user spellchecker/main
#jupyter nbextension enable --user scratchpad/main
#jupyter nbextension enable --user collapsible_headings/main
#jupyter nbextension enable --user codefolding/main

#conda config --env --prepend channels nvidia
conda install -y -S -c conda-forge "cudatoolkit=10.1" "cudnn<=7.6.0"
# NCCL is linux only : conda install -y -S -p $venv -c conda-forge nccl mpi4py gxx_linux-64 gcc_linux-64

conda config --env --prepend channels pytorch
conda config --env --prepend channels fastai
conda config --show-sources
conda install -y -S "fastai=2.0.0" "pytorch=1.7.0" "torchvision=0.8.1" "numpy<1.19.0"
conda install -y -S --file $condatxt
# install pip with no-deps so it doesnt mess up conda installed versions
pip install --no-cache-dir -r $piptxt

conda deactivate

Write-Host " "
Write-Host " "
Write-Host "Activate your environment with  conda activate $venv and then test with pytest -p no:warnings -vv"