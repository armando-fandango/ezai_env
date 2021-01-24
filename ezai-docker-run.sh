#!/usr/bin/env bash

# to pull: docker pull <image>
# to remove image: docker rmi <image>
# to remove container: docker stop <container> && docker rm <container>

cname=${cname:-'ezai-1'}
itag=${itag:-'1.4.5'}
while [ $# -gt 0 ]; do
   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
        #echo $1 $2 #// Optional to see the parameter:value result
   fi
  shift
done
irepo="ghcr.io/armando-fandango" #image repo
iname="${irepo}/ezai:${itag}"   #image name

# docker run -it --gpus all --name phd-gpu-1 -v ${HOME}/datasets:/root/datasets -v /home/armando/phd:/root/phd

# Add this line to your ~/.bashrc
alias eznb='conda activate ezai && xvfb-run -a -s "-screen 0 128x128x24" -- jupyter notebook --ip=* --no-browser'
# test cvfb : xvfb-run -s "-screen 0 1024x768x24" glxgears
#echo "alias eznb='conda activate ezai-conda && jupyter notebook --ip=* --no-browser'" >> ${AI_HOME}/.bashrc &&\

# ports exposed in format -p host-port:container-port
#cports=" -p 8888:8888 " # jupyter notebook
#cports+=" -p 6006:6006 " # tensorboard
#cports+=" -p 4040:4040 " # spark webui
#cports+=" -p 5004:5004 " # unity
#cports+=" -p 5005:5005 " # unity

wfolder=" -w ${HOME}"
vfolders=" "
vfolders+=" -v ${HOME}:${HOME}"
vfolders+=" -v /mnt:/mnt "
vfolders+=" -v /tmp/.X11-unix:/tmp/.X11-unix "
           #-v ${HOME}/.local/share/unity3d /root/.local/share/unity3d "
           #-v ${HOME}/.Xauthority:/root/.Xauthority:rw "
vfolders+=" -v /etc/group:/etc/group:ro"
vfolders+=" -v /etc/passwd:/etc/passwd:ro"
vfolders+=" -v /etc/shadow:/etc/shadow:ro"

#dfile="Dockerfile"
#dfolder="."

# exec options
evars=" -e COMPUTE=${compute} -e DISPLAY -e XAUTHORITY -e NVIDIA_DRIVER_CAPABILITIES=all "
user="-u $(id -u):$(id -g)"
xhost +  # for running GUI app in container

if [ "$(docker image inspect $iname > /dev/null 2>&1 && echo 1 || echo '')" ];
then
  echo "found image $iname"
else
  ezai_pull_image
fi

# HAVE TO CHECK FOR IMAGE AGAIN BECAUSE BULD/PULL FAILS SOMETIME
if [ "$(docker image inspect $iname > /dev/null 2>&1 && echo 1 || echo '')" ];
then
  if [ "$(docker container inspect $cname > /dev/null 2>&1 && echo 1 || echo '')" ];
  then
    echo "found container $cname"
    if [ "$(docker container inspect $cname -f '{{.State.Status}}')"!="running" ]
    then
      echo "attempting to start container $cname"
      docker start "$cname"
    fi
    echo "entering started container $cname"
    docker exec -it $user $wfolder $evars $cname bash
  else
    echo "creating, starting and then entering container $cname"
    # shellcheck disable=SC2154
    docker run -it --gpus all --name $cname \
      $user $wfolder $evars $vfolders $cports $iname bash
  fi
else
   echo "image $iname not found"
fi