#!/bin/bash



if [[ "$1" == "ibex" ]]
then
  ssh upadhyu@glogin.ibex.kaust.edu.sa
elif [[ "$1" == "shaheen" ]]
then
  ssh upadhyu@shaheen.hpc.kaust.edu.sa
fi
