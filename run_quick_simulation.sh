#!/bin/sh

## mainly for testing: do a single run of the pathsim basic simulator ##

BASE_DIR=$1
DATE_RANGE=$2
NSF_DIR=$BASE_DIR/out/network-state/ns-$DATE_RANGE
NUM_SAMPLES=1 #number of simulation runs to do
TRACEFILE=$BASE_DIR/in/users2-processed.traces.pickle
USERMODEL="simple=6000"
FORMAT=$3
ADV_GUARD_BW=0
ADV_EXIT_BW=0
ADV_TIME=0
NUM_ADV_GUARDS=0
NUM_ADV_EXITS=0
NUM_GUARDS=5
GUARD_EXPIRATION=60
LOGLEVEL="DEBUG" #INFO
PATH_ALG="tor"


python pathsim.py simulate --nsf_dir $NSF_DIR --num_samples $NUM_SAMPLES --trace_file $TRACEFILE --user_model $USERMODEL --format $FORMAT --adv_guard_cons_bw $ADV_GUARD_BW --adv_exit_cons_bw $ADV_EXIT_BW --adv_time $ADV_TIME --num_adv_guards $NUM_ADV_GUARDS --num_adv_exits $NUM_ADV_EXITS --num_guards $NUM_GUARDS --guard_expiration $GUARD_EXPIRATION --loglevel $LOGLEVEL $PATH_ALG
