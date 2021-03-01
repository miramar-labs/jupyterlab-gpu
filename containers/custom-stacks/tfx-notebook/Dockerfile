ARG BASE_CONTAINER=whatever
FROM $BASE_CONTAINER

MAINTAINER Aaron Cody <aaron@aaroncody.com>

USER $NB_UID

# Install TFX
RUN pip install --quiet --no-cache-dir 'tfx'

USER $NB_UID