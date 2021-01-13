# build with docker build -t ezml-gpu -f dockerfile-gpu  .
# run with
ARG BASE
FROM $BASE as base-image
MAINTAINER armando@neurasights.com

#ARG COMPONENTS=Unity,Windows,Windows-Mono,Mac,Mac-Mono,WebGL
#ARG COMPONENTS=Unity,Mac,WebGL
ARG COMPUTE=gpu

ENV COMPUTE=$COMPUTE \
    CONDA_DIR="/opt/conda"

USER root

USER root
RUN apt-get -qq update && \
    apt-get -qq upgrade -y && \
    apt-get -qq install -y --no-install-recommends\
    # TODO: sort these package names by alpha - docker BP
      # needed to install custom / launchpad repos
      software-properties-common \
      sudo \
      ca-certificates \
      run-one \
      # avoid curl - use wget
	  wget \
	  bzip2 \
	  # only uncomment for diagnostics
	  #iputils-ping \
	  #htop \
	  nano \
	  # for webdriver - folium
	  firefox-geckodriver \
	  # for matplotlib
	  libgl1-mesa-glx \
	  # for unity
	  mesa-utils \
	  libglu1-mesa-dev \
	  libgles2-mesa-dev \
	  libgl1-mesa-dev \
	  libegl1-mesa-dev \
	  libosmesa6-dev \
	  #libglvnd-dev \
	  xvfb \
	  patchelf \
	  ffmpeg && \
	  apt-get autoremove --purge && apt-get clean && rm -rf /var/lib/apt/lists/*

	#swig \
    # sumo pre-req
	#openjdk-8-jre-headless ca-certificates-java
	# unity pre-req
	#libcurl4-openssl-dev \
	#libgtk2.0-0 \
	#libsoup2.4-1 \
	#libarchive13 \
	#libpng16-16 \
	#libgconf-2-4 \
	#lib32stdc++6 \
	#libcanberra-gtk-module

# Copy a script that we will use to correct permissions after running certain commands
#1 COPY fix-permissions /usr/local/bin/fix-permissions
#1 RUN chmod a+rx /usr/local/bin/fix-permissions

# Create AI_USER and its home
# and make sure these dirs are writable by the group.
#1 RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su && \
#1    sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers && \
#1    sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers && \
#1    useradd -m -s /bin/bash -N -u $AI_UID $AI_UNAME && \
#1    mkdir -p $CONDA_DIR && \
#1    chown $AI_UNAME:$AI_GID $CONDA_DIR && \
#1    chmod g+w /etc/passwd && \
#1    fix-permissions $AI_HOME && \
#1    fix-permissions $CONDA_DIR

#1 USER $AI_UID

WORKDIR /root/
SHELL ["/bin/bash", "-c"]

#Install MINICONDA
COPY install-miniconda.sh /root/
RUN ./install-miniconda.sh --conda_dir ${CONDA_DIR} && rm install-miniconda.sh
ENV PATH=${CONDA_DIR}/bin:$PATH

# create ez conda env

COPY ezai-conda* ezai-pip-* /root/
RUN source ezai-conda.sh && \
    ezai_conda_create --venv "base" && \
    chmod -R 777 ${CONDA_DIR} && \
    rm ezai-conda* ezai-pip-*

#COPY conda-ez-update* /root/
#RUN ./conda-ez-update.sh && \
#    rm conda-ez-update*

    #&& \
    #echo "alias eznb='conda activate ezai-conda && jupyter notebook --ip=* --no-browser'" >> ${AI_HOME}/.bashrc &&\
    #echo "conda activate ezai-conda" >> ${AI_HOME}/.bashrc
                    #--allow-root
# TODO: Make RUN commands use the new environment:
# SHELL ["conda", "run", "-n", "ezai", "/bin/bash", "-c"]
# SHELL ["/bin/bash", "-c"] this doesnt work

# install sumo
# RUN apt-add-repository ppa:sumo/stable
# RUN apt-get -qq install -y sumo sumo-tools sumo-doc

#install unity
#RUN wget -nv https://beta.unity3d.com/download/9e6726e6ce12/UnitySetup-2020.1.0b12 -O UnitySetup && \
#    if [ -n "${SHA1}" -a "${SHA1}" != "" ]; then \
#        echo "${SHA1}  UnitySetup" | sha1sum --check -; \
#    else \
#        echo "no sha1 given, skipping checksum"; \
#    fi && \
#    # make executable
#    chmod +x UnitySetup && \
#    # agree with license
#    echo y | \
#    # install unity with required components
#    ./UnitySetup \
#        --unattended \
#        --install-location=/opt/Unity \
#        --verbose \
#        --components=Unity \
#        --download-location=/tmp/unity && \
    # remove setup & temp files
#    rm UnitySetup && \
#    rm -rf /tmp/unity && \
#    rm -rf /root/.local/share/Trash/*

#RUN /opt/Unity/Editor/Unity -batchmode -nographics -quit -serial SC-B5MY-2GF6-6BB2-NS68-JW9M -username 'armando@neurasights.com' -password ''

# user specific stuff goes here
#RUN mkdir ${$AI_HOME}/.kaggle
#COPY kaggle.json ${AI_HOME}/.kaggle/kaggle.json
#RUN  chmod 600 ${AI_HOME}/.kaggle/kaggle.json
