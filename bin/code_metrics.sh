#!/bin/sh

BIN_DIR=`dirname $0`

cd "BIN_$DIR/.."

for task in flay flog roodi examples bench ruby-prof ruby-prof-exclude; do
    echo "rake $task > metrics/$task 2>&1"
    rake $task > metrics/$task 2>&1
done
