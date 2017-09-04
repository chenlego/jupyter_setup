#!/bin/bash

source ./scripts/jupyter.global

########################################################
echo "============================"
echo "# Remove $ANACONDA_ROOT"
echo "============================"
if [[ -x $ANACONDA_ROOT && -e $ANACONDA_ROOT ]]; then
  rm -rf $ANACONDA_ROOT
fi

echo "============================"
echo "# Remove $JUPYTER_STARTUP_SCRIPT"
echo "============================"
if [[ -x $JUPYTER_STARTUP_SCRIPT && -e $JUPYTER_STARTUP_SCRIPT ]]; then
  rm -f $JUPYTER_STARTUP_SCRIPT
fi

echo "============================"
echo "# Remove $JUPYTER_LOG_DIR"
echo "============================"
if [[ -x $JUPYTER_LOG_DIR && -e $JUPYTER_LOG_DIR ]]; then
  rm -rf $JUPYTER_LOG_DIR
fi

echo "============================"
echo "# Remove $JUPYTER_PID_DIR"
echo "============================"
if [[ -x $JUPYTER_PID_DIR && -e $JUPYTER_PID_DIR ]]; then
  rm -rf $JUPYTER_PID_DIR
fi
