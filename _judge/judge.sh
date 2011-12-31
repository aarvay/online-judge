#!/bin/bash

#  A slick shell script that mimicks the functionality of an online judge. 
#  It performs the following task.

#  [1] Compiles the reference program. Runs it with a series of given inputs 
#      and stores the output for checking against the submissions.

#  [2] Compile, run, and time submissions.

#  [3] Diff the submission's output with the reference output and return the 
#      corresponding success/error message.

#  Author: Vignesh Rajagopalan <vignesh@campuspry.com>. See LICENSE for more
#  details.

#  Developed primarily for use in SASTRA's internal online judge. 

#  For usage, see README.

TEMP=0
declare -a temp_files
trap cleanup EXIT

if [ $# -lt 1 ]; then
  echo "Missing Arguments"
  exit 1
fi

# Parsing arguments with getopts 
# It doesn't handle contiguous args like -cps
while getopts ":c:p:s:l:t:m:" opt; do
  case $opt in
    c) CONTEST_ID=$OPTARG ;;
    p) PROBLEM_ID=$OPTARG ;;
    s) SUBMISSION_ID=$OPTARG ;;
    l) LANGUAGE=$OPTARG ;;
    t) TIME_LIMIT=$OPTARG ;;
    m) MEM_LIMIT=$OPTARG ;;
    \?) echo "Invalid option -$OPTARG" ;;
    :) echo "-$OPTARG requires an argument" ;;
  esac
done
shift $(($OPTIND-1))

if [ -z "${CONTEST_ID+xxx}" ] || [ -z "${LANGUAGE+xxx}" ]; then
  echo "Contest ID or Language is missing."
  exit 1
fi

#Traps exit and cleans up the executables.
function cleanup {
  case $? in
    0) echo "AC" ;;
    1) echo "CE" ;;
    2) echo "RE" ;;
    3) echo "TLE" ;;
    4) echo "WA" ;;
  esac
  for ((i=0;i<${TEMP};i++)); do
    rm ${temp_files[${i}]}
  done
  rm cerrors
}

function compile {
  case $LANGUAGE in
    gcc) compileCommand="gcc -O2 $1 -lm -o $2" ;;
    g++) compileCommand="g++ -O2 $1 -lm -o $2" ;;
    *) echo "Invalid language or not supported." 
      exit 1 ;;
  esac
  $compileCommand 2> cerrors
  if [ $? -ne 0 ]; then
    exit 1
  else
    temp_files[$TEMP]=$2
    ((TEMP++))
  fi
}

function runTests { #Params : Executable, Problem, [name]
  for inp in $( ls $2/input ); do
    if [ -z "${3+xxx}" ]; then
      ./$1 < "$2/input/$inp"  > "$2/output/${inp%.*}.out"
    else
      ./$1 < "$2/input/$inp"  > "$2/output/$3-${inp%.*}.out"
      if [ $? -eq 0 ]; then
        temp_files[$TEMP]="$2/output/$3-${inp%.*}.out"
        ((TEMP++))
      fi
      oup=$( diff "$2/output/${inp%.*}.out" "$2/output/$3-${inp%.*}.out" );
      if [ oup != '\n' ]; then
        exit 4
      fi
    fi
  done
}

function setupProblem {
  pgmLoc="$1/$2/reference"
  for pgm in $( ls $pgmLoc ); do
    op=${pgm%.*}
    pgm="$pgmLoc/$pgm"
    op="$pgmLoc/$op"
    compile $pgm $op
    runTests $op "$1/$2"
  done
}

function setupContest {
  contest=$1
  if [ ! -d "$contest/" ]; then
    echo "Contest ID: $contest does not exist"
    exit 9
  fi
  
  for problem in $( ls $contest ); do
    setupProblem $contest $problem
  done
}

function judgeSubmission {
  sub="$1/$2/submissions/$3"
  case $LANGUAGE in
    g++) ext="cpp" ;;
    gcc) ext="c" ;;
  esac
  compile "$sub.$ext" $sub
  runTests $sub "$1/$2" $3
}

if [ -z "${PROBLEM_ID+xxx}" ]; then
  setupContest $CONTEST_ID
  exit 0
elif [ ! -z "${SUBMISSION_ID+xxx}" ]; then
  judgeSubmission $CONTEST_ID $PROBLEM_ID $SUBMISSION_ID
  exit 0
else
  setupProblem $CONTEST_ID $PROBLEM_ID
  exit 0
fi
