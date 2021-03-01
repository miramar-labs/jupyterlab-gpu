ARG BASE_CONTAINER=jupyter/base-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Aaron Cody <aaron@aaroncody.com>"

USER $NB_UID

# xeus-cling
RUN conda install -c conda-forge xeus-cling

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID
