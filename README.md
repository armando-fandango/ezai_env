# ezai_env
## Description
Docker container and conda virtual environment creation for doing AI on local machines, Kubernetes or SageMaker.

## Pre-requisites for building
- Linux: Python is Installed
- Windows: Python is installed, preferably miniconda.

## Usage

### EZAI in docker environment with conda:

Note: This version maps `$home` directory and `/mnt` directory on the host to docker container, so be careful with modifying anything in these folders inside the container, it will also be modified on the host

Do the following first:
- Download the two files: 
`curl -O "https://raw.githubusercontent.com/armando-fandango/ezai_env/main/{.env,ezai-docker}"`
- modify `.env` file as needed, specially the `itag`
- execute `source ezai-docker`
- now use any of the following commands

#### To run EZAI container
- `ezai_runc`
    - pulls the image if not present
    - starts the container if not started
    - enters the container
- I generally create an alias in bash to run the notebooks from the container quickly:
`alias eznb='conda activate ezai && jupyter notebook --ip=* --no-browser'`

#### To pull EZAI image:
- `ezai_pull_image`

#### To remove EZAI container
- `ezai_rmc`

#### To remove EZAI image
- `ezai_rmi`

#### To build EZAI image
- `ezai_build_image`

### EZAI conda environment on your local machine (no docker):

- modify `ezai-conda-req.txt` as needed
- modify `ezai-pip-req.txt` as needed
- for linux: execute `ezai-conda-create.sh --venv <location-of-env>  --python-ver <python-version>`
    - for windows: execute `ezai-conda-create.ps1 -venv <location-of-env>  -python-ver <python-version>`
    - `<location-of-env>`: Default is `/opt/conda/envs/ezai` on linux and `C:/Miniconda3/envs/ezai` on windows
    - `<python-version>`: Defalult is `3.7`
    - You can supply your own `requirements.txt` files with `--piptxt` and `--condatxt`.
- activate the environment with `conda activate <location-of-env>`
- test the tensorflow and pytroch GPU with `pytest -p no:warnings -vv`

### EZAI conda environment in AWS SageMaker instance:

The SageMaker instance should be already created and stopped before following these steps.

#### On your laptop
- Configure `awscli` if not already done: `aws configure`
- Clone the repo : `git clone https://github.com/armando-fandango/ezai_env.git`
- Go to the `ezai_env` folder where you cloned the repo
- source the file `source ezai-conda` 
- Set the SageMaker env: `set_sagemaker_env -i <instance_name>`

#### Prepare the SageMaker instance
- Launch the instance and open a terminal
- In the terminal: `cd /home/ec2-user/SageMaker/ezai_env`
- Create conda environment: `./ezai-conda-create.sh --venv /home/ec2-user/SageMaker/envs/ezai`
- activate the environment with `conda activate /home/ec2-user/SageMaker/envs/ezai`
- test the tensorflow and pytorch GPU with `pytest -p no:warnings -vv`

#### Test it
- Open the `test.ipynb` file

## TODO:

- Give option to create fully isolated container
- Give option to select which libraries to install
- add/enable more libraries
- make separate dockerfile for Sumo and create only if asked from the run

