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
#  But will work like charm for any production environment.

#  For usage, see README.

VERBOSE=0

if [ $# -lt 1 ]; then
  echo "Missing Arguments"
  exit 1
fi

# Parsing arguments with getopts 
# It doesn't handle contiguous args like -cps
while getopts ":c:p:s:l:t:m:v" opt; do
  case $opt in
    c) CONTEST_ID=$OPTARG ;;
    p) PROBLEM_ID=$OPTARG ;;
    s) SUBMISSION_ID=$OPTARG ;;
    l) LANGUAGE=$OPTARG ;;
    t) TIME_LIMIT=$OPTARG ;;
    m) MEM_LIMIT=$OPTARG ;;
    v) VERBOSE=1 ;;
    \?) echo "Invalid option -$OPTARG" ;;
    :) echo "-$OPTARG requires an argument" ;;
  esac
done
shift $(($OPTIND-1))

if [ -z "${CONTEST_ID+xxx}" ] || [ -z "${LANGUAGE+xxx}" ]; then
  echo "Contest ID or Language is missing."
  exit 1
fi

function compile {
  case $LANGUAGE in
    gcc) compileCommand="gcc -O2 $1 -lm -o $2" ;;
    g++) compileCommand="g++ -O2 $1 -lm -o $2" ;;
    *) echo "Kuch bhi." ;;
  esac
}

function run {
  echo "e"
}

function setupProblem {
  pgmLoc="$1/$2/reference"
  pgm=$( ls $pgmLoc )
  op=${pgm%.*}
  pgm="$pgmLoc/$pgm"
  op="$pgmLoc/$op"
  compile $pgm $op
}

function setupContest {
  contest=$1
  if [ ! -d "$contest/" ]; then
    echo "Contest ID: $contest does not exist"
    exit 1
  fi
  
  for problem in $( ls $contest ); do
    setupProblem $contest $problem
  done
}

function judgeSubmission {
  echo "ju"
}

if [ -z "${PROBLEM_ID+xxx}" ]; then
  setupContest $CONTEST_ID
  exit 0
elif [ ! -z "${SUBMISSION_ID+xxx}" ]; then
  judgeSubmission
  exit 0
else
  setupProblem $CONTEST_ID $PROBLEM_ID
  exit 0
fi
