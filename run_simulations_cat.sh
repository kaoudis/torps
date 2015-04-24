#!/bin/bash

# congestion-aware tor experiment

BASE_DIR=~/Development/Git/torps
SCRIPT=$1
TOT_PROCESSES=512
PARALLEL_PROCESSES=256
DATE_RANGE=$2
NSF_TYPE="slim"
OUTPUT="relay-adv"
ADV_GUARD_BW=15000
ADV_EXIT_BW=10000
ADV_TIME=0
NUM_ADV_GUARDS=1
NUM_ADV_EXITS=1
USERMODEL="bittorrent"
NUM_SAMPLES=${10}
TRACEFILE=$BASE_DIR/in/users2-processed.traces.pickle
LOGLEVEL="INFO"
PATH_ALG=cat
CONGFILE=$BASE_DIR/in/congestion.cator.pickle

EXP_NAME=$USERMODEL.$DATE_RANGE.$ADV_GUARD_BW-$NUM_ADV_GUARDS-$ADV_EXIT_BW-$ADV_TIME-adv.cat
NSF_DIR=$BASE_DIR/out/network-state/$NSF_TYPE/ns-$DATE_RANGE
OUT_DIR=$BASE_DIR/out/simulate/$EXP_NAME
mkdir -p $OUT_DIR
i=1
while [ $i -le $TOT_PROCESSES ]
do
j=1
	while [[ $j -lt $PARALLEL_PROCESSES && $i -lt $TOT_PROCESSES ]]
	do
	# start these in parallel
    	(time pypy $SCRIPT simulate --nsf_dir $NSF_DIR --num_samples $NUM_SAMPLES --trace_file $TRACEFILE --user_model $USERMODEL --format $OUTPUT --adv_guard_cons_bw $ADV_GUARD_BW --adv_exit_cons_bw $ADV_EXIT_BW --adv_time $ADV_TIME --num_adv_guards $NUM_ADV_GUARDS --num_adv_exits $NUM_ADV_EXITS --loglevel $LOGLEVEL $PATH_ALG $CONGFILE) 2> $OUT_DIR/simulate.$EXP_NAME.$NUM_SAMPLES-samples.$i.time 1> $OUT_DIR/simulate.$EXP_NAME.$NUM_SAMPLES-samples.$i.out &
	j=$(($j+1))
    	i=$(($i+1))
	done
# wait for this one to finish
(time pypy $SCRIPT simulate --nsf_dir $NSF_DIR --num_samples $NUM_SAMPLES --trace_file $TRACEFILE --user_model $USERMODEL --format $OUTPUT --adv_guard_cons_bw $ADV_GUARD_BW --adv_exit_cons_bw $ADV_EXIT_BW --adv_time $ADV_TIME --num_adv_guards $NUM_ADV_GUARDS --num_adv_exits $NUM_ADV_EXITS --loglevel $LOGLEVEL $PATH_ALG $CONGFILE) 2> $OUT_DIR/simulate.$EXP_NAME.$NUM_SAMPLES-samples.$i.time 1> $OUT_DIR/simulate.$EXP_NAME.$NUM_SAMPLES-samples.$i.out
i=$(($i+1))
done
