#!/usr/bin/env bash

set -e

PERSISTED_ENVS_DIR="${PERSISTED_ENVS_DIR:-/home/ec2-user/SageMaker/envs}"

sudo  -u ec2-user -i <<'EOF'

PERSISTED_ENVS_DIR="${PERSISTED_ENVS_DIR:-/home/ec2-user/SageMaker/envs}"

echo 'Installing jupyter extensions'

source /home/ec2-user/anaconda3/bin/activate JupyterSystemEnv

echo "Setting jupyter extensions ..."
conda install -y -S -c conda-forge jupyter_contrib_nbextensions jupyter_nbextensions_configurator yapf ipywidgets
jupyter nbextension enable --user code_prettify/code_prettify
jupyter nbextension enable --user toc2/main
jupyter nbextension enable --user varInspector/main
jupyter nbextension enable --user execute_time/ExecuteTime
jupyter nbextension enable --user spellchecker/main
jupyter nbextension enable --user scratchpad/main
jupyter nbextension enable --user collapsible_headings/main
jupyter nbextension enable --user codefolding/main

source /home/ec2-user/anaconda3/bin/deactivate

echo "Setting up persisted conda environments..."
mkdir -p ${PERSISTED_ENVS_DIR} && chown ec2-user:ec2-user ${PERSISTED_ENVS_DIR}

echo "Adding ${PERSISTED_ENVS_DIR} to list of conda env locations"
conda config --prepend envs_dirs /home/ec2-user/anaconda3/envs
conda config --prepend envs_dirs ${PERSISTED_ENVS_DIR}

EOF