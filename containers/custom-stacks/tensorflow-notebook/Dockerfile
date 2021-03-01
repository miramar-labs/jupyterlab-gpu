# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG BASE_CONTAINER=jupyter/scipy-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

# Install Tensorflow
RUN pip install --quiet --no-cache-dir \
    'tensorflow==2.4.1' && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Install JLab Tensorboard
#RUN jupyter labextension install jupyterlab_tensorboard

# Install Tensorboard
RUN pip install --quiet --no-cache-dir 'jupyter-tensorboard'

## BUG FIX for tf 2.4.1 cuda 11.2:
#RUN ln -s /usr/local/cuda-11.2/targets/x86_64-linux/lib/libcusolver.so.11 $(python -c "import tensorflow.python as x; print(x.__path__[0])")/libcusolver.so.10
