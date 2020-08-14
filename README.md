# ezai-docker
Docker container and conda python virtual environment creation for doing AI

To create conda environment:

- modify ezai-conda-env.yaml as needed
- modify ezai-pip-req.txt as needed
- execute ezai-conda-create.sh --venv <location-of-env>  --python-ver <python-version>
    - \<location-of-env> is /opt/conda/env/ezai by default
    - \<python-version> is 3.7 by default
    