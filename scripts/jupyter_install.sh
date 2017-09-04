#!/bin/bash

source ./scripts/jupyter.global

STARTUP_CONFIG_DIR="./startup"
APPEND_CONFIG_DIR="./conf/jupyter"
APPEND_CONFIG="$APPEND_CONFIG_DIR/jupyter_notebook_config.append.py"

########################################################
echo "============================"
echo "==== Create jupyter user ===="
echo "============================"
# Create jupyter user
id $JUPYTER_USER
if [[ $? -ne 0 ]]; then
  useradd $JUPYTER_USER --shell=/sbin/nologin --no-create-home --no-user-group --uid=2014 --home=${ANACONDA_ROOT}
fi

########################################################
echo "==============================="
echo "= Install Jupyter by Anaconda ="
echo "==============================="
if [[ ! -e $ANACONDA_ROOT ]]; then
  # you can pick which version you want on https://repo.continuum.io/archive/
  wget https://repo.continuum.io/archive/${ANACONDA_VER}
  bash ${ANACONDA_VER} -p $ANACONDA_ROOT
  if [[ $? -eq 0 ]]; then
    chown ${JUPYTER_USER} -R /opt/anaconda
    rm -f ${ANACONDA_VER}
  else
    echo "${ANACONDA_VER} install fail"
    exit 255
  fi
fi

########################################################
echo "==============================================="
echo "= Generate Jupyter notebook configuration file ="
echo "==============================================="
# Configure jupyter server config
if [[ ! -e $CONFIG ]]; then
  mkdir -p ${JUPYTER_CONF_DIR}
  ${ANACONDA_BIN}/jupyter notebook --generate-config --config=${CONFIG} --allow-root
  cat ${APPEND_CONFIG} >> ${CONFIG}
  PASSWD=$(${ANACONDA_BIN}/python ./jupyter_passwd.py)
  echo "c.NotebookApp.password = '$PASSWD'" >> $CONFIG
  chown ${JUPYTER_USER} -R ${JUPYTER_CONF_DIR}
fi

########################################################
echo "============================"
echo "==== Setup related dirs ===="
echo "============================"

if [[ ! -d ${JUPYTER_LOG_DIR} ]]; then
  mkdir -p ${JUPYTER_LOG_DIR}
  chown $JUPYTER_USER $JUPYTER_LOG_DIR
fi

if [[ ! -d ${JUPYTER_PID_DIR} ]]; then
  mkdir -p ${JUPYTER_PID_DIR}
  chown $JUPYTER_USER $JUPYTER_PID_DIR
fi

if [[ ! -d ${JUPYTER_NOEBOOK_DIR} ]]; then
  mkdir -p ${JUPYTER_NOEBOOK_DIR}
  chown $JUPYTER_USER ${JUPYTER_NOEBOOK_DIR}
fi

########################################################
echo "============================"
echo "=== Setup startup config ==="
echo "============================"
# Generate startup config and script
JUPYTER_SETUP_BIN="$ANACONDA_BIN"
JUPYTER_SETUP_DAEMON="${ANACONDA_BIN}/jupyter-notebook"
JUPYTER_SETUP_DAEMON_ARGS="--config=$CONFIG --notebook-dir=${JUPYTER_NOEBOOK_DIR}"
cat ${STARTUP_CONFIG_DIR}/jupyter.script.template | sed -e "s#JUPYTER_SETUP_BIN#$JUPYTER_SETUP_BIN#g" \
    -e "s#JUPYTER_SETUP_DAEMON_ARGS#$JUPYTER_SETUP_DAEMON_ARGS#g" \
    -e "s#JUPYTER_SETUP_DAEMON#$JUPYTER_SETUP_DAEMON#g" \
    -e "s#JUPYTER_SETUP_USER#${JUPYTER_USER}#g" \
    -e "s#JUPYTER_SETUP_LOG#${JUPYTER_LOG}#g" \
    -e "s#JUPYTER_SETUP_PID_FILE#${JUPYTER_PID_FILE}#g" \
    > ${STARTUP_CONFIG_DIR}/jupyter.tmp
mv -f ${STARTUP_CONFIG_DIR}/jupyter.tmp ${JUPYTER_STARTUP_SCRIPT}
chmod +x /usr/sbin/jupyter

# add startup services
cat ${STARTUP_CONFIG_DIR}/jupyter.service.template | sed -e "s#JUPYTER_SETUP_USER#${JUPYTER_USER}#g" > ${SYSTEMD_DIR}/${JUPYTER_SERVICE}
systemctl enable jupyter.service

# configure Apache
#mkdir -p $SHARE_DIR
#chown -R nobody:nobody $SHARE_DIR

# config for Admin UI
#cp ./conf/httpd/jupyter_admin.conf

# config for Share
#cp ./conf/httpd/jupyter_admin.conf
