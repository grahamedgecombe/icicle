#!/bin/sh -e
export PYTHONPATH=`dirname $0`
exec yosys "$PYTHONPATH/equiv.ys"
