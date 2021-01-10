#!/usr/bin/env bash

ezai_build_image() {

  source .env

  dfile="Dockerfile"
  dfolder="."

  if [ "$(docker image inspect $iname > /dev/null 2>&1 && echo 1 || echo '')" ];
  then
    echo "found image $iname.. rebuilding"
  else
    echo "creating image $iname"
  fi

  if [ $compute == "gpu" ];
  then
    base="nvidia/cuda:10.1-cudnn7-runtime-ubuntu18.04"
  else
    base="ubuntu:18.04"
  fi
  barg=" --build-arg BASE=$base "
  barg+=" --build-arg COMPUTE=$compute "
  bopt=" "
#  bopt+=" --no-cache "
#  barg+=" --build-arg AI_UID=${AI_UID} "
#  barg+=" --build-arg AI_GID=${AI_GID} "
#  barg+=" --build-arg AI_UNAME=${AI_UNAME} "
  docker build $bopt -t $iname $barg -f $dfile $dfolder

  # HAVE TO CHECK FOR IMAGE AGAIN BECAUSE BUILD FAILS SOMETIME
  if [ "$(docker image inspect $iname > /dev/null 2>&1 && echo 1 || echo '')" ];
  then
     echo "created image $iname"
  else
     echo "not created image $iname"
  fi
}

ezai_pull_image() {
    echo "pulling image $iname"
    docker pull $iname
}

ezai_runc () {
    # TODO: instead of root, run as user
  # docker run -it --gpus all --name phd-gpu-1 -v ${HOME}/datasets:/root/datasets -v /home/armando/phd:/root/phd

  # Add this line to your ~/.bashrc
  alias eznb='conda activate ezai && xvfb-run -a -s "-screen 0 128x128x24" -- jupyter notebook --ip=* --no-browser'
  # test cvfb : xvfb-run -s "-screen 0 1024x768x24" glxgears
  #echo "alias eznb='conda activate ezai-conda && jupyter notebook --ip=* --no-browser'" >> ${AI_HOME}/.bashrc &&\

  source .env

  #dfile="Dockerfile"
  #dfolder="."

  # exec options
  evars=" -e COMPUTE=${compute} -e PROJECT=${project} -e DISPLAY -e XAUTHORITY -e NVIDIA_DRIVER_CAPABILITIES=all "
  user="-u ${AI_UID}:${AI_GID}"
  xhost +  # for running GUI app in container

  if [ "$(docker image inspect $iname > /dev/null 2>&1 && echo 1 || echo '')" ];
  then
    echo "found image $iname"
  else
    ezai_pull_image
  fi

  # HAVE TO CHECK FOR IMAGE AGAIN BECAUSE BULD FAILS SOMETIME
  if [ "$(docker image inspect $iname > /dev/null 2>&1 && echo 1 || echo '')" ];
  then
    if [ "$(docker ps -q -f name=$cname -f status=exited)" ];
    then
      echo "starting container $cname"
      docker start "$cname"
    fi
    if [ "$(docker ps -q -f name="$cname" -f status=running)" ];
    then
      echo "entering started container $cname"
      # shellcheck disable=SC2154
      docker exec -it $user $wfolder $evars $cname bash
    else
      echo "creating, starting and then entering container $cname"
      # shellcheck disable=SC2154
      docker run -it --gpus all --name $cname \
        $user $wfolder $evars $vfolders $cports $iname bash
    fi
  else
     echo "not pulled image $iname"
  fi

}

ezai_rmi () {
  # remove the docker image

  source .env

  docker rmi $iname --no-prune
}

ezai_rmc () {
  # stop and remove the docker container

  source .env
  #export $(grep --regexp ^[a-z] .env | cut -d= -f1)

  #docker container exec $cname /opt/Unity/Editor/Unity -batchmode -nographics -quit -serial SC-B5MY-2GF6-6BB2-NS68-JW9M -username 'armando@neurasights.com' -password '' -returnlicense
  docker container stop $cname
  docker container rm $cname
}