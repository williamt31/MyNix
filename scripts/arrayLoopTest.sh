#!/bin/bash

dirs=(  "/tmp/1" \
        "/tmp/2" \
        "/tmp/3" )

wget=(  "tmp1"  \
        "tmp2"  \
        "tmp3" )


for i in "${!dirs[@]}"
do
        mkdir ${dirs[$i]}
        cd    ${dirs[$i]}
        touch ${wget[$i]}
done
