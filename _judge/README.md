judge.sh
========
This is a slick bash script that mimics the functionality of a code checker.

Introduction
------------
It performs the following task.

* Compiles the reference program. Runs it with a series of given inputs and 
  stores the output for checking against the submissions.

* Compile, run, and time submissions.

* Diff the submission's output with the reference output and return the 
  corresponding success/error message.

Setting up a contest
--------------------
Setting up a contest is really simple. Just the understanding of the structure 
of the judge will do. Every contest is a directory inside _judge/ and each 
problem is a sub-directory. The directory's name is the corresponding id 
(Contest ID or Problem ID).

### Structure of the Judge
      
    _judge/
      |__ _contestid/
      |__ _contestid/
      .
      .
      .
      |__ _contestid/
            |__ problemid/
            |__ problemid/
            .
            .
            .
            |__ problemid/
                  |__ input/
                  |__ output/
                  |__ reference/
                  |__ submissions/
                        |__ submissionid
                        |__ submissionid
                        .
                        .
                        .
                        |__ submissionid
            |__ problemid/
      |__ contestid/

Usage
-----
The script has the following arguments.

1. -c (CONTEST_ID)
2. -p (PROBLEM_ID)
3. -s (SUBMISSION_ID)
4. -l (LANGUAGE) (Currently supports only gcc & g++)
5. -t (TIME_LIMIT)
6. -m (MEMORY_LIMIT)

### The script has three different usages.

#### 1. Setup the entire contest.

    ./judge.sh -cCONTEST_ID -lLANGUAGE

Example :

    ./judge.sh -cJAN12 -lg++

This will setup the entire contest with the ID = "JAN12". This assumes that all
the reference implementations within this contest are in g++.

#### 2. Setup a particular problem within the contest.

    ./judge.sh -cCONTEST_ID -pPROBLEM_ID -lLANGUAGE

Example :

    ./judge.sh -cJAN12 -pROCKS -lgcc

This is used when the contest has reference implementations in different 
languages. Each problem in the contest has to be setup individually.

#### 3. Judge Submission.

    ./judge.sh -cCONTEST_ID -pPROBLEM_ID -sSUBMISSION_ID -lLANGUAGE -tTIME_LIMIT -mMEMORY_LIMIT

Example :

    ./judge.sh -cJAN12 -pROCKS -s23 -lg++ -t2 -m64
