ARG BASE_CONTAINER=whatever
FROM $BASE_CONTAINER

MAINTAINER Aaron Cody <aaron@aaroncody.com>

USER $NB_UID
##---------------------------- PyTorch ----------------------------
# install pytorch/cuda
RUN pip install torch torchvision
##---------------------------- fast.ai ----------------------------
# install fast.ai prereqs
USER root

RUN apt-get update && apt-get install -y graphviz

USER $NB_UID

RUN pip install pyarrow

RUN pip install fastai2 pydicom kornia opencv-python scikit-image

USER $NB_UID