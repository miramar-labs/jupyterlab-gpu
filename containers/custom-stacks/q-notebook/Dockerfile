ARG BASE_CONTAINER=jwhatever
FROM $BASE_CONTAINER

MAINTAINER Aaron Cody <aaron@aaroncody.com>

USER $NB_UID
##---------------------------- Q ----------------------------
# install Q
RUN pip install qiskit qiskit-terra[visualization]
##---------------------------- DONE ----------------------------
USER $NB_UID