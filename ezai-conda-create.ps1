#!/usr/bin/env pwsh

#TODO: probably change this default to ~/envs once docker is implemented
param ($venv='c:/Miniconda3/envs/ezai', $py_ver='3.7', $piptxt='./ezai-pip-req.txt', $condatxt='./ezai-conda-req.txt')

# add -k if ssl_verify needs to be set to false
$opts="--strict-channel-priority"
$channels="-c conda-forge"

function ProceedOrExit {
    if ($?) { echo "Proceed.." } else { echo "Script FAILED! Exiting.."; exit 1 }
}

Write-Host "creating $venv with python $py_ver ..."
echo "conda create -y -p $venv $channels $opts python=$py_ver"
conda create -y -p $venv $channels $opts python=$py_ver jupyter notebook jupyter_contrib_nbextensions jupyter_nbextensions_configurator
conda activate $venv
conda config --env --prepend channels conda-forge
conda config --env --set channel_priority strict
conda config --env --remove channels defaults
conda config --set auto_activate_base false
jupyter nbextension enable code_prettify/code_prettify
jupyter nbextension enable toc2/main
        #jupyter nbextension enable ipyparallel && \

$channels+=" -c pytorch "
$channels+=" -c fastai "

conda install -y -p $venv $channels -c defaults cudatoolkit=10.1 cudnn=7.6.5
conda install -y -p $venv $channels nccl mpi4py
conda install -y -p $venv $channels $opts --file $condatxt --prune
    # install pip with no-deps so it doesnt mess up conda installed versions
pip install --no-deps --use-feature 2020-resolver -r $piptxt

Write-Host " "
Write-Host " "
Write-Host " For Linux 64, Open MPI is built with CUDA awareness but this support is disabled by default."
Write-Host "To enable it, please set the environmental variable OMPI_MCA_opal_cuda_support=true before"
Write-Host "launching your MPI processes. Equivalently, you can set the MCA parameter in the command line:"
Write-Host "mpiexec --mca opal_cuda_support 1 ..."

Write-Host " "
Write-Host " "
Write-Host "Activate your environment with  conda activate ${venv}"


