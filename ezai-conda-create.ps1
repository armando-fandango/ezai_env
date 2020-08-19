#!/usr/bin/env pwsh

#TODO: probably change this default to ~/envs once docker is implemented
param ($venv='c:/Miniconda3/envs/ezai', $py_ver='3.7', $piptxt='./ezai-pip-req.txt', $condatxt='./ezai-conda-req.txt')

# add -k if ssl_verify needs to be set to false
$opts="--strict-channel-priority"

function ProceedOrExit {
    if ($?) { echo "Proceed.." } else { echo "Script FAILED! Exiting.."; exit 1 }
}

Write-Host "creating $venv with python $py_ver ..."
echo "conda create -y -p $venv $channels $opts python=$py_ver"
conda create -y -p $venv -c conda-forge -c defaults $opts python=$py_ver jupyter notebook jupyter_contrib_nbextensions jupyter_nbextensions_configurator cudatoolkit=10.1 cudnn=7.6.5
conda activate $venv
conda config --env --prepend channels conda-forge
conda config --env --set channel_priority strict
conda config --env --remove channels defaults
conda config --set auto_activate_base false
jupyter nbextension enable code_prettify/code_prettify
jupyter nbextension enable toc2/main
        #jupyter nbextension enable ipyparallel && \

#conda install -y -p $venv $channels -c defaults cudatoolkit=10.1 cudnn=7.6.5
conda install -y -p $venv -c conda-forge -c pytorch -c fastai -c defaults $opts --file $condatxt --prune
    # install pip with no-deps so it doesnt mess up conda installed versions
pip install --no-deps --use-feature 2020-resolver -r $piptxt

Write-Host " "
Write-Host " "
Write-Host "Activate your environment with  conda activate ${venv}"


