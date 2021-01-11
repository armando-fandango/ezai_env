#!/usr/bin/env bash

#venv='ezai'

activate () {
  conda activate $1 || source activate $1
}

deactivate () {
  conda deactivate || source deactivate
}

install_jupyter () {
  echo "Installing jupyter ..."
  conda install -y -S -c conda-forge "ipython>=7.0.0" "notebook>=6.0.0" jupyter_contrib_nbextensions jupyter_nbextensions_configurator yapf ipywidgets ipykernel
  return $?
}

install_jupyter_extensions () {
  echo "Setting jupyter extensions ..."
  conda install -y -S -c conda-forge jupyter_contrib_nbextensions jupyter_nbextensions_configurator yapf ipywidgets && \
  jupyter nbextension enable --sys-prefix code_prettify/code_prettify  && \
  jupyter nbextension enable --sys-prefix toc2/main && \
  jupyter nbextension enable --sys-prefix varInspector/main && \
  jupyter nbextension enable --sys-prefix execute_time/ExecuteTime && \
  jupyter nbextension enable --sys-prefix spellchecker/main && \
  jupyter nbextension enable --sys-prefix scratchpad/main && \
  jupyter nbextension enable --sys-prefix collapsible_headings/main && \
  jupyter nbextension enable --sys-prefix codefolding/main
  return $?
}

# sets passed prefix env as jupyter kernel
install_jupyter_kernel () {
  kernel_name='ezai'
  kernel_disp_name='ezai'
  conda install -y -S -c conda-forge ipykernel
  python -m ipykernel install --prefix="$1" --name $kernel_name --display-name $kernel_disp_name
  return $?
}

create_venv () {
  echo "$venv doesnt exist - creating now with python $py_ver ..."
  conda create -y -p "${venv}" -c conda-forge "python=${py_ver}" "conda=4.6.14" "pip=20.2.2"
  return $?
}

install_venv () {
  echo "installing python $py_ver in $venv..."
  conda install -y -S -c conda-forge "python=${py_ver}" "conda=4.6.14" "pip=20.2.2"
  return $?
}

config_env () {
  conda config --env --append channels conda-forge && \
  conda config --env --set auto_update_conda False && \
  #conda config --env --set channel_priority strict && \
  conda config --env --remove channels defaults
  return $?
}

#install_jupyter () {
#  echo "Installing jupyter ..."
#  conda install -y -S -c conda-forge "ipython>=7.0.0" "notebook>=6.0.0" jupyter_contrib_nbextensions jupyter_nbextensions_configurator yapf ipywidgets ipykernel && \
#  jupyter nbextension enable --user code_prettify/code_prettify  && \
#  jupyter nbextension enable --user toc2/main && \
#  jupyter nbextension enable --user varInspector/main && \
#  jupyter nbextension enable --user execute_time/ExecuteTime && \
#  jupyter nbextension enable --user spellchecker/main && \
#  jupyter nbextension enable --user scratchpad/main && \
#  jupyter nbextension enable --user collapsible_headings/main && \
#  jupyter nbextension enable --user codefolding/main && \
#  return $?
#}

install_cuda () {
  echo "Installing cuda ..."
  conda install -y -S -c conda-forge -c defaults "cudatoolkit=10.1" "cudnn>=7.6.5" && \
  conda install -y -S "nccl" #"mpi4py>=3.0.0" gxx_linux-64 gcc_linux-64
  return $?
}

install_fastai_pytorch () {
  echo "Installing fastai and pytorch ..."
  conda config --env --prepend channels pytorch
  conda config --env --prepend channels fastai
  conda config --show-sources
  # numpy spec due to tensorflow and pillow spec due to gym
  conda install -y -S "fastai=2.0.0" "pytorch=1.6.0" "torchvision=0.7.0" "numpy<1.19.0" #"gym=0.18.0"
  return $?
}

install_txt () {
  conda config --show-sources
  conda install -y -S --file $condatxt && \
  # install pip with no-deps so it doesnt mess up conda installed versions
  pip install --no-deps --no-cache-dir -r "$piptxt"
  return $?
}

ezai_conda_create () {
  venv=${venv:-$(conda info --base)/envs/ezai}
  piptxt=${piptxt:-"./ezai-pip-req.txt"}
  condatxt=${condatxt:-"./ezai-conda-req.txt"}
  # add -k if ssl_verify needs to be set to false
  #source $(conda info --base)/etc/profile.d/conda.sh

  py_ver=${py_ver:-3.7.3}

  while [ $# -gt 0 ]; do
     if [[ $1 == *"--"* ]]; then
          param="${1/--/}"
          declare $param="$2"
          echo $1 $2 #// Optional to see the parameter:value result
     fi
    shift
  done

  conda clean -i
  echo $venv

  if [ "${venv}" != "base" ];
  then
    echo "setting base conda to 4.6.14, python to 3.7.3"
    activate base
    conda config --env --set auto_update_conda False
    conda config --show-sources
    conda install -y --no-update-deps "conda=4.6.14" "python=3.7.3" || (echo "Unable to update base conda"; exit 1)
    deactivate

    activate "${venv}" || create_venv || (echo "Unable to create ${venv}" ; exit 1)
  else
    activate "${venv}" && install_venv
    deactivate
  fi

  activate "${venv}" && config_env
  deactivate

  activate "${venv}" && ( install_cuda && install_fastai_pytorch && install_txt )
  deactivate

  # Expose environment as kernel
  #python -m ipykernel install --user --name ezai-conda --display-name "ezai-conda"

  # TODO: Uncomment below in final version
  if [ "${venv}" != "base" ];
  then
    activate "${venv}" &&  conda clean -ypt
    deactivate
  fi
  activate base && conda clean -ypt
  deactivate
  # TODO: Uncomment above in final version
  echo " "
  echo " "
  echo " For Linux 64, Open MPI is built with CUDA awareness but this support is disabled by default."
  echo "To enable it, please set the environmental variable OMPI_MCA_opal_cuda_support=true before"
  echo "launching your MPI processes. Equivalently, you can set the MCA parameter in the command line:"
  echo "mpiexec --mca opal_cuda_support 1 ..."

  echo " "
  echo " "
  echo "Activate your environment with  conda activate $venv  and then test with pytest -p no:warnings -vv"
}

set_sagemaker_env () {

  # prepare instance for lifecycle configuration
  INSTANCE_NAME=${INSTANCE_NAME:-'ai-playground'}
  while [ $# -gt 0 ]; do
    case $1 in
      -i|--instance-name)
        #param="${1/--/}"
        declare INSTANCE_NAME="$2"
        ;;
      -c|--clean)
        local CLEAN='true'
    esac
    shift
  done

  echo "Stopping instance $INSTANCE_NAME"
  aws sagemaker stop-notebook-instance \
      --notebook-instance-name "$INSTANCE_NAME"
  aws sagemaker wait notebook-instance-stopped \
      --notebook-instance-name "$INSTANCE_NAME"

  CONFIGURATION_NAME=$(aws sagemaker describe-notebook-instance --notebook-instance-name "${INSTANCE_NAME}" | jq -e '.NotebookInstanceLifecycleConfigName | select (.!=null)' | tr -d '"')
  echo "Configuration [\"$CONFIGURATION_NAME\"] attached to notebook instance $INSTANCE_NAME"

  if [[ -z "$CLEAN" ]]; then
    # clean variable is not defined

    # add repo to instance
#    update_params=' --additional-code-repositories "https://github.com/armando-fandango/ezai_env.git" '
    ATTACHED_EZAI_ENV=$(aws sagemaker describe-notebook-instance --notebook-instance-name "${INSTANCE_NAME}" | jq -e '.AdditionalCodeRepositories | map(select (.=="ezai-env"))[0]' | tr -d '"')
    if [[ -z "$ATTACHED_EZAI_ENV" ]]; then
      # there is no attached repo, attach it
      echo "Attaching repo ezai-env ..."

      REPO_EZAI_ENV=$(aws sagemaker list-code-repositories --name-contains 'ezai-env' | jq -e '.CodeRepositorySummaryList[] | .CodeRepositoryName' | tr -d '"')
      if [[ -z "$REPO_EZAI_ENV" ]]; then
        echo "ezai-env code repo not present in sagemaker, creating repo ezai-env ..."
        aws sagemaker create-code-repository \
          --code-repository-name "ezai-env" \
          --git-config '{"Branch":"main", "RepositoryUrl" :
            "https://github.com/armando-fandango/ezai_env.git" }'
      else
        echo "ezai-env code repo present in sagemaker"
      fi

      aws sagemaker update-notebook-instance \
        --notebook-instance-name "$INSTANCE_NAME" \
        --additional-code-repositories "ezai-env"

      aws sagemaker wait notebook-instance-stopped \
        --notebook-instance-name "$INSTANCE_NAME"
    fi

    if [[ -z "$CONFIGURATION_NAME" ]]; then
        # there is no attached configuration name, create a new one
        CONFIGURATION_NAME="ezai-sagemaker"
        CONFIG_EZAI_PRESENT = $(aws sagemaker list-notebook-instance-lifecycle-configs --name-contains $CONFIGURATION_NAME | jq -e '.NotebookInstanceLifecycleConfigs[] | .NotebookInstanceLifecycleConfigName' | tr -d '"' )
        if [[ -z "$CONFIG_EZAI_PRESENT" ]]; then
          echo "Creating new configuration $CONFIGURATION_NAME..."
          aws sagemaker create-notebook-instance-lifecycle-config \
            --notebook-instance-lifecycle-config-name "$CONFIGURATION_NAME" \
            --on-start Content=$(echo '#!/usr/bin/env bash'| base64) \
            --on-create Content=$(echo '#!/usr/bin/env bash' | base64)
        else
          echo "Found existing configuration $CONFIGURATION_NAME"
        fi
        aws sagemaker update-notebook-instance \
            --notebook-instance-name "$INSTANCE_NAME" \
            --lifecycle-config-name "$CONFIGURATION_NAME"

        aws sagemaker wait notebook-instance-stopped \
            --notebook-instance-name "$INSTANCE_NAME"
        # attaching lifecycle configuration to the notebook instance
        #update_params+=" --lifecycle-config-name "+"$CONFIGURATION_NAME"
    fi
    #echo "Attaching repo ezai_env and configuration $CONFIGURATION_NAME to ${INSTANCE_NAME}..."
    #aws sagemaker update-notebook-instance \
    #    --notebook-instance-name "$INSTANCE_NAME" \
    #    $update_params
    #aws sagemaker wait notebook-instance-stopped \
    #    --notebook-instance-name "$INSTANCE_NAME"


    echo "Downloading on-start.sh..."
    # save the existing on-start script into on-start.sh
    aws sagemaker describe-notebook-instance-lifecycle-config \
        --notebook-instance-lifecycle-config-name "$CONFIGURATION_NAME" | jq '.OnStart[0].Content'  | tr -d '"' | base64 --decode > on-start.sh

    echo "Adding extensions install to on-start.sh..."
    echo '' >> on-start.sh
    #echo '# update ezai_env' >> on-start.sh
    #echo 'cd /home/ec2-user/SageMaker/ezai_env' >> on-start.sh
    #echo 'git stash' >> on-start.sh
    #echo 'git pull --rebase' >> on-start.sh
    echo '# configure sagemaker as per ezai' >> on-start.sh
    #echo "export PIP_PACKAGE_NAME=\"${PIP_PACKAGE_NAME}\"" >> on-start.sh
    #echo "export EXTENSION_NAME=\"${EXTENSION_NAME}\"" >> on-start.sh
    echo 'cat /home/ec2-user/SageMaker/ezai_env/sagemaker/on-start.sh | bash' >> on-start.sh
  else
    if [[ -z "$CONFIGURATION_NAME" ]]; then
      echo "No config attached, nothing to empty"
    else
      echo "creating empty  on-start.sh..."
      echo '' > on-start.sh
    fi
  fi

  if [[ -z "$CONFIGURATION_NAME" ]]; then
    echo ""
  else
    echo "Uploading on-start.sh..."
    # update the lifecycle configuration config with updated on-start.sh script
    aws sagemaker update-notebook-instance-lifecycle-config \
      --notebook-instance-lifecycle-config-name "$CONFIGURATION_NAME" \
      --on-start Content="$( (cat on-start.sh)| base64)"
    aws sagemaker wait notebook-instance-stopped \
      --notebook-instance-name "$INSTANCE_NAME"
    rm on-start.sh
  fi
}

sagemaker_lifecycle_download () {

  INSTANCE_NAME='ai-playground'

  echo "Downloading on-start.sh..."
  # save the existing on-start script into on-start.sh
  aws sagemaker describe-notebook-instance-lifecycle-config \
    --notebook-instance-lifecycle-config-name "$CONFIGURATION_NAME" | jq '.OnStart[0].Content'  | tr -d '"' | base64 --decode > on-start.sh
}

sagemaker_lifecycle_upload () {

  INSTANCE_NAME='ai-playground'

  CONFIGURATION_NAME=$(aws sagemaker describe-notebook-instance --notebook-instance-name "${INSTANCE_NAME}" | jq -e '.NotebookInstanceLifecycleConfigName | select (.!=null)' | tr -d '"')
  echo "Configuration \"$CONFIGURATION_NAME\" attached to notebook instance $INSTANCE_NAME"

  echo "Uploading on-start.sh..."
  # update the lifecycle configuration config with updated on-start.sh script
  aws sagemaker update-notebook-instance-lifecycle-config \
      --notebook-instance-lifecycle-config-name "$CONFIGURATION_NAME" \
      --on-start Content="$((cat on-start.sh)| base64)"
}

#while [[ "$#" -gt 0 ]]
#  do
#    case $1 in
#      -f|--follow)
#        local FOLLOW="following"
#        ;;
#      -t|--tail)
#        local TAIL="tail=$2"
#        ;;
#    esac
#    shift
#  done