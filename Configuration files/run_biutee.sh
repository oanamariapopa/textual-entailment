#!/bin/sh

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
raw_input_file="NAME OF FILE USED.xml"
ser_input_file="NAME OF FILE USED TO BUILD THE TREE.ser"
model_dir="model"
results_file="results.log"
resources="WORDNET,VERB_OCEAN,SYNTACTIC"
num_threads="1"
easyfirst_port="8080"
opt_mode="ignore_dataset_and_optimize_accuracy"
gap=false


function show_help() {
    echo
    echo "run_biutee.sh [OPTIONS] MODE"
    echo
    echo "Available modes:  lap_train"
    echo "                  train"
    echo "                  lap_train,train"
    echo "                  lap_test"
    echo "                  test"
    echo "                  lap_test,test"
    echo "                  visual"
    echo
    echo "Options:"
    echo " -h               show help"
    echo " -i <filename>    raw input file (rte pairs format)"
    echo " -s <filename>    serialized input file (saves/loads the preprocessed pairs after LAP)"
    echo " -m <dir>         models directory"
    echo " -o <filename>    results file (only in test modes)"
    echo " -r <list>        list of resources, separated by commas (no spaces)"
    echo " -t <int>         number of threads"
    echo " -e <port>        easyfirst parser's port"
    echo " -f               optimize F1 (instead of accuracy)"
    echo " -g               gap mode"
    echo
}


### Argument parsing. ###

while getopts "hi:s:m:o:r:t:e:" opt; do
    case "$opt" in
    h)  show_help
        exit 0
        ;;
    i)  raw_input_file=$OPTARG
        ;;
    s)  ser_input_file=$OPTARG
        ;;
    m)  model_dir=$OPTARG
        ;;
    o)  results_file=$OPTARG
        ;;
    r)  resources=$OPTARG
        ;;
    t)  num_threads=$OPTARG
        ;;
    e)  easyfirst_port=$OPTARG
        ;;
    f)  opt_mode="ignore_dataset_and_optimize_f1"
        ;;
    g)  gap=true
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

mode=$@
case $mode in
    lap_train)
        ;;
    lap_train,train)
        ;;
    train)
        ;;
    lap_test)
        ;;
    lap_test,test)
        ;;
    test)
        ;;
    visual)
        ;;
    *)
        echo "Invalid mode: $mode"
        exit 1
        ;;
esac

# Parsed all arguments! Now display them.

echo
echo "raw_input_file = $raw_input_file"
echo "ser_input_file = $ser_input_file"
echo "model_dir = $model_dir"
echo "results_file = $results_file"
echo "resources = $resources"
echo "num_threads = $num_threads"
echo "easyfirst_port = $easyfirst_port"
echo "opt_mode = $opt_mode"
echo "gap = $gap"
echo "mode = $mode"
echo


### Actual work begins here. ###

# Make sure model dir exists.
mkdir -p $model_dir

# Remove syntactic from resources.
mw_resources=`echo $resources | sed "s/SYNTACTIC//g" | sed "s/,,/,/g" | sed "s/^,//g" | sed "s/,$//g"`

#Create temp config.
cat biutee_template.xml \
    | sed "s=RAW_INPUT_FILE=$raw_input_file=g" \
    | sed "s=SER_INPUT_FILE=$ser_input_file=g" \
    | sed "s=MODEL_DIR=$model_dir=g"           \
    | sed "s/RESOURCES/$resources/g"           \
    | sed "s/MWSOURCES/$mw_resources/g"        \
    | sed "s/NUM_THREADS/$num_threads/g"       \
    | sed "s/EASYFIRST_PORT/$easyfirst_port/g" \
    | sed "s/OPT_MODE/$opt_mode/g" \
    | sed "s/GAP/$gap/g" \
    > biutee_temp.xml

# Run easyfirst, and save pid.
./runeasyfirst.sh $easyfirst_port &
easyfirst_pid=$!

# Run BIUTEE.
main_class=`echo "eu.excitementproject.eop.biutee.rteflow.systems.excitement.BiuteeMain"`

# Run the tracer if visual mode was selected
if [ "$mode" = "visual" ] 
then
    main_class=`echo "eu.excitementproject.eop.biutee.rteflow.systems.gui.VisualTracingTool"`
fi

mvn -f ../../../../../biutee/pom.xml exec:java -Dexec.mainClass=${main_class} -Dexec.arguments="-d64 -Xms512m -Xmx4g -XX:-UseGCOverheadLimit -XX:+UseConcMarkSweepGC" -Dexec.args="biutee_temp.xml $mode" 

# Terminate easyfirst.
pkill -P $easyfirst_pid

# If in train modes, copy models to model dir.
if [ "$mode" = "train" ] || [ "$mode" = "lap_train,train" ]
then
    cp model*.xml $model_dir
fi

# If in test modes, generate results file.
if [ "$mode" = "test" ] || [ "$mode" = "lap_test,test" ]
then
    cat logfile.log | grep "confidence" | sed "s/^.*Decision for //g" > "$results_file"
fi

echo
echo "DONE!"
echo

