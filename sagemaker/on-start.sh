#!/usr/bin/env bash

set -e

sudo  -u ec2-user -i <<'EOF'
cd /home/ec2-user/SageMaker/ezai_docker
git stash
git pull --rebase
source /home/ec2-user/SageMaker/ezai_docker/ezai
source /home/ec2-user/anaconda3/bin/activate JupyterSystemEnv
set_jupyter_extensions
source /home/ec2-user/anaconda3/bin/deactivate
EOF