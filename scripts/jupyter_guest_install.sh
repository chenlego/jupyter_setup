#!/bin/bash

source ./scripts/jupyter.global

STARTUP_CONFIG_DIR="./startup"
APPEND_CONFIG_DIR="./conf/jupyter"
APPEND_CONFIG="$APPEND_CONFIG_DIR/jupyter_notebook_config_guest.append.py"

########################################################
echo "============================"
echo "=== Guest part ============="
echo "============================"

########################################################
echo "============================"
echo "=== Create jupyter guest ==="
echo "============================"
# Create jupyter guest
id $JUPYTER_GUEST
if [[ $? -ne 0 ]]; then
  useradd $JUPYTER_GUEST --shell=/sbin/nologin --no-create-home --no-user-group --uid=2015 --home=/tmp
fi

########################################################
echo "==============================================="
echo "= Generate Jupyter notebook configuration file ="
echo "==============================================="
# Configure jupyter server config
if [[ ! -e $CONFIG_FOR_GUEST ]]; then
  mkdir -p ${JUPYTER_CONF_DIR}
  ${ANACONDA_BIN}/jupyter notebook --generate-config --config=${CONFIG_FOR_GUEST} --allow-root
  cat ${APPEND_CONFIG} >> ${CONFIG_FOR_GUEST}
fi

########################################################
echo "============================"
echo "==== Setup related dirs ===="
echo "============================"

if [[ ! -d ${JUPYTER_GUEST_LOG_DIR} ]]; then
  mkdir -p ${JUPYTER_GUEST_LOG_DIR}
  chown $JUPYTER_GUEST $JUPYTER_GUEST_LOG_DIR
fi

########################################################
echo "============================"
echo "=== Setup startup config ==="
echo "============================"
# Generate startup config and script
JUPYTER_SETUP_BIN="$ANACONDA_BIN"
JUPYTER_SETUP_DAEMON="${ANACONDA_BIN}/jupyter-notebook"
JUPYTER_SETUP_DAEMON_ARGS="--config=$CONFIG_FOR_GUEST --notebook-dir=${JUPYTER_NOEBOOK_DIR}"
cat ${STARTUP_CONFIG_DIR}/jupyter.script.template | sed -e "s#JUPYTER_SETUP_BIN#$JUPYTER_SETUP_BIN#g" \
    -e "s#JUPYTER_SETUP_DAEMON_ARGS#$JUPYTER_SETUP_DAEMON_ARGS#g" \
    -e "s#JUPYTER_SETUP_DAEMON#$JUPYTER_SETUP_DAEMON#g" \
    -e "s#JUPYTER_SETUP_USER#${JUPYTER_GUEST}#g" \
    -e "s#JUPYTER_SETUP_LOG#${JUPYTER_GUEST_LOG}#g" \
    -e "s#JUPYTER_SETUP_PID_FILE#${JUPYTER_GUEST_PID_FILE}#g" \
    > ${STARTUP_CONFIG_DIR}/jupyter.tmp
mv -f ${STARTUP_CONFIG_DIR}/jupyter.tmp ${JUPYTER_GUEST_STARTUP_SCRIPT}
chmod +x ${JUPYTER_GUEST_STARTUP_SCRIPT}

# add startup services
cat ${STARTUP_CONFIG_DIR}/jupyter.service.template | sed -e "s#JUPYTER_SETUP_USER#${JUPYTER_GUEST}#g" \
    -e "s#JUPYTER_SETUP_STARTUP_SCRIPT#${JUPYTER_GUEST_STARTUP_SCRIPT}#g" > ${SYSTEMD_DIR}/${JUPYTER_GUEST_SERVICE}
systemctl enable ${JUPYTER_GUEST_SERVICE}
