#!/bin/sh
BASE_DIR=~/Development/Git/torps
DATE_RANGE="2013-04--2015-04"
NSF_DIR=$BASE_DIR/out/network-state/ns-$DATE_RANGE
NUM_SAMPLES=1
TRACEFILE=$BASE_DIR/in/users2-processed.traces.pickle
USERMODEL="simple=6000"
FORMAT="testing"
ADV_GUARD_BW=0
ADV_EXIT_BW=0
ADV_TIME=0
NUM_ADV_GUARDS=0
NUM_ADV_EXITS=0
NUM_GUARDS=3
GUARD_EXPIRATION=60
LOGLEVEL="INFO"
PATH_ALG="tor"
python pathsim.py simulate --nsf_dir $NSF_DIR --num_samples $NUM_SAMPLES --trace_file $TRACEFILE --user_model $USERMODEL --format $FORMAT --adv_guard_cons_bw $ADV_GUARD_BW --adv_exit_cons_bw $ADV_EXIT_BW --adv_time $ADV_TIME --num_adv_guards $NUM_ADV_GUARDS --num_adv_exits $NUM_ADV_EXITS --num_guards $NUM_GUARDS --guard_expiration $GUARD_EXPIRATION --loglevel $LOGLEVEL $PATH_ALG
