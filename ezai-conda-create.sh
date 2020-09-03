#!/usr/bin/env bash

# We imort conda command as sometimes it doesnt work otherwise
if [[ "${OSTYPE}" == 'cygwin' ]]
then
  export SHELLOPTS # should be after or before set ?
  set -o igncr # execute it manually for now it doesnt work
  source /cygdrive/c/Miniconda3/etc/profile.d/conda.sh
  venv=${venv:-$(conda info --base)/envs/ezai}
else
  source $(conda info --base)/etc/profile.d/conda.sh
  venv=${venv:-$(conda info --base)/envs/ezai}
fi

# add -k if ssl_verify needs to be set to false
#pkgs="jupyter notebook jupyter_contrib_nbextensions jupyter_nbextensions_configurator"

piptxt=${piptxt:-"./ezai-pip-req.txt"}
condatxt=${condatxt:-"./ezai-conda-req.txt"}

py_ver=${py_ver:-3.7.8}

while [ $# -gt 0 ]; do
   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
        # echo $1 $2 // Optional to see the parameter:value result
   fi
  shift
done

activate () {
  conda activate $1 || source activate $1
}

deactivate () {
  conda deactivate || source deactivate
}

install_python () {
  echo "$venv doesnt exist - creating now with python $py_ver ..."
  conda create -y -p $venv -c conda-forge python=$py_ver "conda=4.6.14" "pip=20.2.2" && \
  activate $venv && \
  conda config --env --append channels conda-forge && \
  conda config --env --set auto_update_conda False && \
  #conda config --env --set channel_priority strict && \
  conda config --env --remove channels defaults
  return $?
}

install_jupyter () {
  echo "Installing jupyter ..."
  conda install -y -S -c conda-forge "ipython>=7.0.0" "notebook>=6.0.0" jupyter_contrib_nbextensions jupyter_nbextensions_configurator yapf ipywidgets ipykernel && \
  jupyter nbextension enable --user code_prettify/code_prettify  && \
  jupyter nbextension enable --user toc2/main && \
  jupyter nbextension enable --user varInspector/main && \
  jupyter nbextension enable --user execute_time/ExecuteTime && \
  jupyter nbextension enable --user spellchecker/main && \
  jupyter nbextension enable --user scratchpad/main && \
  jupyter nbextension enable --user collapsible_headings/main && \
  jupyter nbextension enable --user codefolding/main && \
  return $?
}

install_cuda () {
  echo "Installing cuda ..."
  conda install -y -S -c conda-forge -c defaults "cudatoolkit=10.1" "cudnn>=7.6.5" && \
  conda install -y -S "nccl" "mpi4py>=3.0.0" gxx_linux-64 gcc_linux-64
  return $?
}

install_fastai_pytorch () {
  echo "Installing fastai and pytorch ..."
  conda config --env --prepend channels pytorch
  conda config --env --prepend channels fastai
  conda config --show-sources
  conda install -y -S "fastai=2.0.0" "pytorch=1.6.0" "torchvision=0.7.0" "numpy<1.19.0"
  return $?
}

install_txt () {
  conda config --show-sources
  conda install -y -S --file $condatxt && \
  # install pip with no-deps so it doesnt mess up conda installed versions
  pip install --no-deps --use-feature 2020-resolver -r $piptxt
  return $?
}

opts=" --strict-channel-priority"

conda clean -i
echo "setting base conda to 4.6.14 and pip to 20.2.2"
activate base
conda config --env --set auto_update_conda False
conda config --show-sources
conda install -y -S "conda=4.6.14" "pip=20.2.2" "python=3.7"
deactivate

activate $venv || install_python
deactivate

#channels+=" -c pytorch "
#channels+=" -c fastai "
activate $venv && ( install_jupyter && install_cuda && install_fastai_pytorch && install_txt )

echo " "
echo " "
echo " For Linux 64, Open MPI is built with CUDA awareness but this support is disabled by default."
echo "To enable it, please set the environmental variable OMPI_MCA_opal_cuda_support=true before"
echo "launching your MPI processes. Equivalently, you can set the MCA parameter in the command line:"
echo "mpiexec --mca opal_cuda_support 1 ..."

echo " "
echo " "
echo "Activate your environment with  conda activate $venv  and then test with pytest -p no:warnings -vv"

deactivate