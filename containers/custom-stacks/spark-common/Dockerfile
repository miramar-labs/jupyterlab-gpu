ARG BASE_CONTAINER=whatever
FROM $BASE_CONTAINER

LABEL maintainer="Aaron Cody <aaron@aaroncody.com>"

USER $NB_UID

## sparkmagic
RUN pip install sparkmagic

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID

