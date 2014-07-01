#!/bin/sh
NAME="shorty"
cd `dirname $0`
erl -name ${NAME}@127.0.0.1 -pa $PWD/ebin $PWD/deps/*/ebin -s $NAME -s reloader \
    +K         true \
#    +A         32 \
    -env       ERL_MAX_PORTS 64000 \
    -env       ERL_FULLSWEEP_AFTER 0 \
    -smp       enable \
    +zdbbl     32768 \
    -setcookie $NAME
