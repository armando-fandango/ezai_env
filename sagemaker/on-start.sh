#!/usr/bin/env bash

set -e

PERSISTED_ENVS_DIR="${PERSISTED_ENVS_DIR:-/home/ec2-user/SageMaker/envs}"

sudo  -u ec2-user -i <<'EOF'

PERSISTED_ENVS_DIR="${PERSISTED_ENVS_DIR:-/home/ec2-user/SageMaker/envs}"

echo 'Installing jupyter extensions'
source /home/ec2-user/SageMaker/ezai_docker/ezai
source /home/ec2-user/anaconda3/bin/activate JupyterSystemEnv
set_jupyter_extensions
source /home/ec2-user/anaconda3/bin/deactivate

echo "Setting up persisted conda environments..."
mkdir -p ${PERSISTED_ENVS_DIR} && chown ec2-user:ec2-user ${PERSISTED_ENVS_DIR}

envdirs_clean=$(grep "envs_dirs:" /home/ec2-user/.condarc || echo "clean")
if [[ "${envdirs_clean}" != "clean" ]]; then
    echo 'envs_dirs config already exists in /home/ec2-user/.condarc. No idea what to do. Exiting!'
    exit 1
fi

echo "Adding ${PERSISTED_ENVS_DIR} to list of conda env locations"
cat << EOG >> /home/ec2-user/.condarc
envs_dirs:
  - ${PERSISTED_ENVS_DIR}
  - /home/ec2-user/anaconda3/envs
EOG

EOF