#!/usr/bin/env bash

#------------------------------   Help Messages  ----------------------------

#get script name
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

#Print usage message
print_usage() 
{
  cat <<EOF
Usage: $SCRIPT_NAME [options] <tb_file>

EOF
}

#Print options message
print_options() 
{
  cat <<EOF
Options:
  -h                    Display help message
  -c                    Run simulation in terminal, using CLI mode
  -d  <do_file>         Specify a non-default do file to run simulation with

EOF
}

#Print help message
print_help() 
{
  print_usage
  print_options
  cat <<EOF
Description:
  Script will simulate the <tb_file> testbench.

  By default script will run the simulation in GUI mode, and will attempt to use the
  testbench's default do file (do file named <tb_file>.do, located in do directory).
  If no default do file exists, simulation will run without a do file.

Note:
  Script should be placed in, and run from the projects root directory.

EOF
}

#--------------------  Make sure we are running in projects root directory  -----------

#GET PROJECTS ROOT DIREDCTORY
PROJECT_ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#make sure we are running only from projects root directory
#if not then exit script
if [ "$(pwd)" != "$PROJECT_ROOT_DIR" ] ; then
  echo "Error: Please run script from project root directory"
  print_usage
  exit 1
fi

#--------------------  Parse options -------------------------------------------

CLI_MODE="false"    #by default we dont run in CLI mode
DO_FILE=""          #if -d flag isnt set, this will stay empty

while getopts ":hcd:" FLAG; do
  case "$FLAG" in
    c)
      CLI_MODE="true"
      ;;
    d)
      #check for valid do file
      if [[ "$OPTARG" == -* ]] ; then   #if arg is a flag, then we didnt pass a .do file
        echo "Error: -d missing do file"
        exit 1
      elif [[ "$OPTARG" != *.do ]] ; then   #make sure arg is a .do file
        echo "Error: -d invalid do file"
        exit 1
      fi

      #get absolute path to do file
      DO_FILE="$(cd "$(dirname "$OPTARG")" && pwd)/$(basename "$OPTARG")"
      ;;
    h)
      print_help
      exit 0
      ;;
    :)
      echo "Error: missing option argument -$OPTARG"
      exit 1
      ;;
    \?)
      echo "Error: unknown option -$OPTARG"
      exit 1
      ;;
  esac
done

#shift to the remaining arguments
shift $((OPTIND-1))


#-------------------- process test_bench argument  -----------------------------------

#check for too many arguments
if [ $# -gt 1 ] ; then
  echo 'Error: too many arguments'
  print_usage
  exit 1
fi

#check if file testbench file was given
if [ -z "$1" ] ; then
  echo 'Error: no testbench file specified'
  print_usage
  exit 1
fi

#get test bench from passed arg, and strip its path and file extension
TEST_BENCH_PATH="$1"
TEST_BENCH=${TEST_BENCH_PATH##*/}  #strip path from TEST_BENCH
TEST_BENCH=${TEST_BENCH%.*}   #strip .sv from TEST_BENCH


#-------------------- get correct do file ------------------------------------------

#get do file
if [[ ! -n "$DO_FILE" ]] ; then   #if a do file was not set by the -d flag
  if [[ -f "$PROJECT_ROOT_DIR/do/$TEST_BENCH.do" ]] ; then  #if default do file exists
    DO_FILE="$PROJECT_ROOT_DIR/do/$TEST_BENCH.do"   #get abs path to do file
  fi
fi


#-------------------- ensure sim directory exists      ------------------------------

#Check if sim directory exists at project root, if not the create it
if [ ! -d "$PROJECT_ROOT_DIR/sim" ] ; then 
  echo "no simulation directory found"
  echo $'creating ./sim directory\n'
  mkdir -p "$PROJECT_ROOT_DIR/sim"
fi

cd "$PROJECT_ROOT_DIR/sim"  || exit 1

#Check if modelsim directory exists in sim dir, if not create it
if [ ! -d 'modelsim' ] ; then 
  echo "no modelsim directory found"
  echo $'creating ./sim/modelsim directory\n'
  mkdir -p modelsim
fi

cd modelsim || exit 1

#Check if modelsim working dir exists, if not create it
if [ ! -d 'work' ] ; then 
  echo "no modelsim work directory found"
  echo $'creating ./sim/modelsim/work directory\n'
  vlib work
fi

#-------------------- compile all rtl files ------------------------------

echo "COMPILING RTL FILES:"
echo $'\n'
vlog "$PROJECT_ROOT_DIR"/rtl/*.sv
echo $'\n'

#-------------------- compile test_bench ------------------------------

echo "COMPILING TEST BENCH: $TEST_BENCH"
echo $'\n'
vlog "$PROJECT_ROOT_DIR/$TEST_BENCH_PATH"
echo $'\n'

#-------------------- run the simulation    ------------------------------

echo "SIMULATING TEST BENCH: $TEST_BENCH"
echo $'\n'

#create do command
DO="$DO_FILE"               #by default use the do file
if [[ ! -n "$DO" ]] ; then  #but if there is none, then just run -all
  echo "WARNING:  Default do file ($TEST_BENCH.do) not found."
  echo "          Running sim with no do file"
  echo $'\n'

  DO="run -all"
fi

if [ "$CLI_MODE" = "true" ] ; then        #if we are in cli mode 
  vsim "$TEST_BENCH" -c -do "$DO"
else                                      #else we are in GUI mode
  vsim "$TEST_BENCH" -quiet -do "$DO"
fi
