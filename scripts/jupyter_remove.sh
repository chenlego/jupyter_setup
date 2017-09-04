#!/bin/bash

source ./scripts/jupyter.global

########################################################
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

echo "============================"
echo "# Remove $SHARE_DOCUMENT_ROOT"
echo "============================"
if [[ -x $SHARE_DOCUMENT_ROOT && -e $SHARE_DOCUMENT_ROOT ]]; then
  echo "rename only: $SHARE_DOCUMENT_ROOT to ${SHARE_DOCUMENT_ROOT}.backup"
  echo "you can delete it by yourself with rm -rf ${SHARE_DOCUMENT_ROOT}.backup"
  mv -f $SHARE_DOCUMENT_ROOT ${SHARE_DOCUMENT_ROOT}.backup
fi

echo "============================"
echo "# Remove $ANACONDA_ROOT"
echo "============================"
if [[ -x $ANACONDA_ROOT && -e $ANACONDA_ROOT ]]; then
  rm -rf $ANACONDA_ROOT
  echo "rename only: $ANACONDA_ROOT to ${ANACONDA_ROOT}.backup"
  echo "you can delete it by yourself with rm -rf ${ANACONDA_ROOT}.backup"
  mv -f $ANACONDA_ROOT ${ANACONDA_ROOT}.backup
fi
