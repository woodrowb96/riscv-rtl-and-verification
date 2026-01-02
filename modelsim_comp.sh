#!/bin/bash

#Get projects root directory
PROJECT_ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

#make sure script is run only from the projects root directory
if [ "$(pwd)" != "$PROJECT_ROOT_DIR" ] ; then
  echo "Error: please run script from project root directory (where the script is located)"
  echo "Usage   cd $PROJECT_ROOT_DIR"
  echo "        ./$SCRIPT_NAME <path-to-file>"
  exit 1
fi

#check for too many arguments
if [ $# -gt 1 ] ; then
  echo 'Error: too many arguments'
  echo "Usage: ./$SCRIPT_NAME <path-to-file>"
  exit 1
fi

#check if file to be compiled was given, then compile it
if [ -z "$1" ] ; then
  echo 'Error: no file specified'
  echo "Usage: ./$SCRIPT_NAME <path-to-file>"
  exit 1
fi

#Check if sim directory exists at project root, if not the create it
if [ ! -d "$PROJECT_ROOT_DIR/sim" ] ; then 
  echo "no simulation directory found"
  echo $'creating ./sim directory\n'
  mkdir $PROJECT_ROOT_DIR/sim
fi

#Check if modelsim directory exists in sim dir, if not create it
cd $PROJECT_ROOT_DIR/sim
if [ ! -d 'modelsim' ] ; then 
  echo "no modelsim directory found"
  echo $'creating ./sim/modelsim directory\n'
  mkdir modelsim
fi

#Check if modelsim working dir exists, if not create it
cd modelsim
if [ ! -d 'work' ] ; then 
  echo "no modelsim work directory found"
  echo $'creating ./sim/modelsim/work directory\n'
  vlib work
fi

#compile file
vlog $PROJECT_ROOT_DIR/$1
