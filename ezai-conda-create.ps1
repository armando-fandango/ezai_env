#!/usr/bin/env pwsh

conda_base=$(conda info --base)
#TODO: probably change this default to ~/envs once docker is implemented
param ($venv=$conda_base+'/envs/ezai', $py_ver='3.7.8', $piptxt='./ezai-pip-req.txt', $condatxt='./ezai-conda-req.txt')

# add -k if ssl_verify needs to be set to false
$opts="--strict-channel-priority"

function ProceedOrExit {
    if ($?) { echo "Proceed.." } else { echo "Script FAILED! Exiting.."; exit 1 }
}

Write-Host "setting base conda to 4.6.14"
conda activate base
conda config --set auto_update_conda False
conda install -y -S conda=4.6.14
conda deactivate

Write-Host "creating $venv with python $py_ver ..."
echo "conda create -y -p $venv -c conda-forge python=$py_ver"
conda create -y -p $venv -c conda-forge python=$py_ver

conda activate $venv
conda config --env --append channels conda-forge
conda config --env --set channel_priority strict
conda config --env --remove channels defaults
conda config --set auto_activate_base false

conda install -y -S -p $venv -c conda-forge "ipython>7.0" "notebook>=6.0.0" jupyter_contrib_nbextensions jupyter_nbextensions_configurator yapf ipywidgets
jupyter nbextension enable code_prettify/code_prettify
jupyter nbextension enable toc2/main
jupyter nbextension enable varInspector/main
jupyter nbextension enable execute_time/ExecuteTime
jupyter nbextension enable spellchecker/main
jupyter nbextension enable scratchpad/main
jupyter nbextension enable collapsible_headings/main
jupyter nbextension enable codefolding/main

conda install -y -S -p $venv -c conda-forge -c defaults "cudatoolkit=10.1" "cudnn=7.6.5"
#conda install -y -S -p $venv -c conda-forge nccl mpi4py gxx_linux-64 gcc_linux-64
conda config --env --prepend channels pytorch
conda config --env --prepend channels fastai

conda install -y -S -p $venv -c fastai -c pytorch -c conda-forge "fastai=2.0.0" "pytorch=1.6.0" "torchvision=0.7.0" "numpy<1.19.0"

conda install -y -S -p $venv -c fastai -c pytorch -c conda-forge --file $condatxt
# install pip with no-deps so it doesnt mess up conda installed versions
pip install --no-deps --use-feature 2020-resolver -r $piptxt

Write-Host " "
Write-Host " "
Write-Host "Activate your environment with  conda activate $venv and then test with pytest -p no:warnings -vv"


