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
  -t  <tcl_file>         Specify a non-default tcl script to run simulation with

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
  testbench's default tcl file (tcl file named <tb_file>.tcl, located in tcl directory).
  If no default do file exists, simulation will run without a tcl file.

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
TCL_FILE=""          #if -t flag isnt set, this will stay empty

while getopts ":hcd:" FLAG; do
  case "$FLAG" in
    c)
      CLI_MODE="true"
      ;;
    t)
      #check for valid do file
      if [[ "$OPTARG" == -* ]] ; then   #if arg is a flag, then we didnt pass a .tcl file
        echo "Error: -t missing tcl file"
        exit 1
      elif [[ "$OPTARG" != *.tcl ]] ; then   #make sure arg is a .tcl file
        echo "Error: -t invalid tcl file"
        exit 1
      fi

      #get absolute path to tcl file
      TCL_FILE="$(cd "$(dirname "$OPTARG")" && pwd)/$(basename "$OPTARG")"
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
if [[ ! -n "$TCL_FILE" ]] ; then   #if a tcl file was not set by the -t flag
  if [[ -f "$PROJECT_ROOT_DIR/waves/xsim/$TEST_BENCH.tcl" ]] ; then  #if default tcl file exists
    TCL_FILE="$PROJECT_ROOT_DIR/waves/xsim/$TEST_BENCH.tcl"   #get abs path to tcl file
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
if [ ! -d 'xsim' ] ; then 
  echo "no xsim directory found"
  echo $'creating ./sim/xsim directory\n'
  mkdir -p xsim
fi

cd xsim || exit 1

#-------------------- compile all rtl files ------------------------------

echo "COMPILING RTL FILES:"
echo $'\n'
for RTL_FILE in "$PROJECT_ROOT_DIR"/rtl/*.sv ; do
  [ -f "$RTL_FILE" ] || break
  xvlog -sv "$RTL_FILE"
  echo $'\n'
done
echo $'\n'

#-------------------- compile test_bench ------------------------------

echo "COMPILING TEST BENCH: $TEST_BENCH"
echo $'\n'
xvlog -sv "$PROJECT_ROOT_DIR/$TEST_BENCH_PATH"
echo $'\n'

#-------------------- elaborate test_bench ------------------------------

echo "ELABORATING TEST BENCH: $TEST_BENCH"
echo $'\n'
xelab $TEST_BENCH -debug typical
echo $'\n'

#-------------------- run the simulation    ------------------------------

echo "SIMULATING TEST BENCH: $TEST_BENCH"
echo $'\n'

#create do command
TCL="$TCL_FILE"               #by default use the TCL file
if [[ ! -n "$TCL" ]] ; then  #but if there is none, then just run -all
  echo "WARNING:  Default TCL file ($TEST_BENCH.tcl) not found."
  echo "          Running sim with no tcl file"
  echo $'\n'
fi


if [ "$CLI_MODE" = "true" ] ; then        #if we are in cli mode 
  if [ -n "$TCL" ] ; then
    xsim $TEST_BENCH -tclbatch "$TCL"
  else
    xsim $TEST_BENCH -runall
  fi
else                                      #else we are in GUI mode
  if [ -n "$TCL" ] ; then
    xsim $TEST_BENCH -gui -tclbatch "$TCL"
  else
    xsim $TEST_BENCH -gui
  fi
fi
