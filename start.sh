#!/bin/sh
cd `dirname $0`
NAME="shorty"
export HEART_COMMAND="erl -heart"
screen -dmS $NAME -t $NAME \
    erl -heart -name "${NAME}@127.0.0.1" -pa $PWD/ebin $PWD/deps/*/ebin -s $NAME -s reloader \
        +K         true \
        +A         128 \
        -env       ERL_MAX_PORTS 64000 \
        -env       ERL_FULLSWEEP_AFTER 0 \
        -smp       enable \
        +zdbbl     32768 \
        -setcookie $NAME
