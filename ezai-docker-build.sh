#!/usr/bin/env bash

irepo="ghcr.io/armando-fandango" #image repo
itag="1.4.5" #image tag
iname="${irepo}/ezai:${itag}"   #image name
dfile="Dockerfile"
dfolder="."

if [ "$(docker image inspect $iname > /dev/null 2>&1 && echo 1 || echo '')" ];
then
  echo "found image $iname.. rebuilding"
else
  echo "creating image $iname"
fi

base="nvidia/cuda:10.2-cudnn7-runtime-ubuntu18.04"

barg=" --build-arg BASE=$base "
bopt=" "
bopt+=" --no-cache "
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
