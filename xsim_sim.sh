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
  -g                    Run simulation using the gui
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

  By default script will run the simulation in cli mode, and will attempt to use the
  testbench's default tcl file (tcl file named <tb_file>.tcl, located in tcl directory).
  If no default do file exists, simulation will run without a tcl file.

Note:
  Script should be placed in, and run from the projects root directory.

EOF
}

#--------------------Create some dir path variables -----------

#the root directory, where the sim scripts live
PROJECT_ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#rtl directories
RTL_DIR="$PROJECT_ROOT_DIR/rtl"
RTL_PKG_DIR="$RTL_DIR/package"

#verification directories
VERIFY_DIR="$PROJECT_ROOT_DIR/verify"
VERIFY_PKG_DIR="$VERIFY_DIR/package"
ASSERT_DIR="$VERIFY_DIR/assert"
COVERAGE_DIR="$VERIFY_DIR/coverage"
INTERFACE_DIR="$VERIFY_DIR/interface"
REF_MODEL_DIR="$VERIFY_DIR/ref_model"
STIMULUS_DIR="$VERIFY_DIR/stimulus"
TB_DIR="$VERIFY_DIR/tb"

#scripts dir
SCRIPTS_DIR="$PROJECT_ROOT_DIR/scripts/xsim"

#--------------------  Make sure we are running in projects root directory  -----------

#make sure we are running only from projects root directory
#if not then exit script
if [ "$(pwd)" != "$PROJECT_ROOT_DIR" ] ; then
  echo "Error: Please run script from project root directory"
  print_usage
  exit 1
fi

#--------------------  Parse options -------------------------------------------

GUI_MODE="false"    #by default we dont run in CLI mode
TCL_FILE=""          #if -t flag isnt set, this will stay empty

while getopts ":hgt:" FLAG; do
  case "$FLAG" in
    g)
      GUI_MODE="true"
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
  if [[ -f "$SCRIPTS_DIR/$TEST_BENCH.tcl" ]] ; then  #if default tcl file exists
    TCL_FILE="$SCRIPTS_DIR/$TEST_BENCH.tcl"   #get abs path to tcl file
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

#Check if xsim directory exists in sim dir, if not create it
if [ ! -d 'xsim' ] ; then 
  echo "no xsim directory found"
  echo $'creating ./sim/xsim directory\n'
  mkdir -p xsim
fi

cd xsim || exit 1
#-------------------- compile all rtl packages  ------------------------------

if [ -d "$RTL_PKG_DIR" ] ; then           #if we have packages, then compile
  echo "COMPILING RTL PACKAGE FILES:"
  echo $'\n'
  for RTL_PACKAGE_FILE in "$RTL_PKG_DIR"/*.sv ; do
    [ -f "$RTL_PACKAGE_FILE" ] || break
    xvlog -sv "$RTL_PACKAGE_FILE"
    echo $'\n'
  done
  echo $'\n'
fi

#-------------------- compile all rtl files ------------------------------

if [ -d "$RTL_DIR" ] ; then
  echo "COMPILING RTL FILES:"
  echo $'\n'
  for RTL_FILE in "$RTL_DIR"/*.sv ; do
    [ -f "$RTL_FILE" ] || break
    xvlog -sv "$RTL_FILE"
    echo $'\n'
  done
  echo $'\n'
else
  echo "WARNING: no rtl directory found at $RTL_DIR"
fi

#-------------------- compile all verify packages  ------------------------------

if [ -d "$VERIFY_PKG_DIR" ] ; then
  echo "COMPILING VERIFY PACKAGE FILES:"
  echo $'\n'
  for VERIFY_PACKAGE_FILE in "$VERIFY_PKG_DIR"/*.sv ; do
    [ -f "$VERIFY_PACKAGE_FILE" ] || break
    xvlog -sv "$VERIFY_PACKAGE_FILE"
    echo $'\n'
  done
  echo $'\n'
fi

#-------------------- compile all interface files ------------------------------

if [ -d "$INTERFACE_DIR" ] ; then
  echo "COMPILING INTERFACE FILES:"
  echo $'\n'
  for INTERFACE_FILE in "$INTERFACE_DIR"/*.sv ; do
    [ -f "$INTERFACE_FILE" ] || break
    xvlog -sv "$INTERFACE_FILE"
    echo $'\n'
  done
  echo $'\n'
fi

#-------------------- compile all assertions files ------------------------------

if [ -d "$ASSERT_DIR" ] ; then
  echo "COMPILING ASSERT FILES:"
  echo $'\n'
  for ASSERT_FILE in "$ASSERT_DIR"/*.sv ; do
    [ -f "$ASSERT_FILE" ] || break
    xvlog -sv "$ASSERT_FILE"
    echo $'\n'
  done
  echo $'\n'
fi

#-------------------- compile all coverage files ------------------------------

if [ -d "$COVERAGE_DIR" ] ; then
  echo "COMPILING COVERAGE FILES:"
  echo $'\n'
  for COVERAGE_FILE in "$COVERAGE_DIR"/*.sv ; do
    [ -f "$COVERAGE_FILE" ] || break
    xvlog -sv "$COVERAGE_FILE"
    echo $'\n'
  done
  echo $'\n'
fi

#-------------------- compile all stimulus files ------------------------------

if [ -d "$STIMULUS_DIR" ] ; then
  echo "COMPILING STIMULUS FILES:"
  echo $'\n'
  for STIMULUS_FILE in "$STIMULUS_DIR"/*.sv ; do
    [ -f "$STIMULUS_FILE" ] || break
    xvlog -sv "$STIMULUS_FILE"
    echo $'\n'
  done
  echo $'\n'
fi

#-------------------- compile all ref models files ------------------------------

if [ -d "$REF_MODEL_DIR" ] ; then
  echo "COMPILING REF_MODEL FILES:"
  echo $'\n'
  for REF_MODEL_FILE in "$REF_MODEL_DIR"/*.sv ; do
    [ -f "$REF_MODEL_FILE" ] || break
    xvlog -sv "$REF_MODEL_FILE"
    echo $'\n'
  done
  echo $'\n'
fi

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
#
# #-------------------- run the simulation    ------------------------------

echo "SIMULATING TEST BENCH: $TEST_BENCH"
echo $'\n'

#create do command
TCL="$TCL_FILE"               #by default use the TCL file
if [[ ! -n "$TCL" ]] ; then  #but if there is none, then just run -all
  echo "WARNING:  Default TCL file ($TEST_BENCH.tcl) not found."
  echo "          Running sim with no tcl file"
  echo $'\n'
fi

#run in cli or in gui
if [ "$GUI_MODE" = "true" ] ; then        #if we are in gui mode
  if [ -n "$TCL" ] ; then
    xsim $TEST_BENCH -gui -tclbatch "$TCL"
  else
    xsim $TEST_BENCH -gui
  fi
else                                      #else we are in CLI mode
  if [ -n "$TCL" ] ; then
    xsim $TEST_BENCH -tclbatch "$TCL"
  else
    xsim $TEST_BENCH -runall
  fi
fi
