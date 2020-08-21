# ezai-docker
Docker container and conda python virtual environment creation for doing AI

## To create conda environment:

- modify `ezai-conda-req.txt` as needed
- modify `ezai-pip-req.txt` as needed
- execute `ezai-conda-create.sh --venv <location-of-env>  --python-ver <python-version>`
    - `<location-of-env>` is `/opt/conda/envs/ezai` by default
    - `<python-version>` is `3.7` by default
    - You can supply your own `requirements.txt` files with `--piptxt` and `--condatxt`.
- activate the environment with `conda activate <location-of-env>`
- test the tensorflow and pytroch GPU with `pytest -p no:warnings -vv`

## to create a docker environment with conda:

    