ARG BASE_CONTAINER=jupyter/base-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Aaron Cody <aaron@aaroncody.com>"

USER root

RUN echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook

# NFS
EXPOSE 2049
EXPOSE 111
EXPOSE 20048

# Various utils
RUN apt-get update && apt-get install -y apt-utils nfs-common netbase openssh-server iputils-ping netcat curl vim tree gcc git

# kubectl Support
RUN curl -LOs https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl
RUN mkdir -p /home/$NB_USER/.kube
ADD admin.conf /home/$NB_USER/.kube/config

# JLab user environment
COPY init.sh /env-init.sh
RUN fix-permissions /env-init.sh

USER $NB_UID

# re-use buildbox SSH keys for git etc...
RUN mkdir /home/$NB_USER/.ssh
ADD id_rsa /home/$NB_USER/.ssh/id_rsa
ADD id_rsa.pub /home/$NB_USER/.ssh/id_rsa.pub
ADD config /home/$NB_USER/.ssh/config
ADD authorized_keys /home/$NB_USER/.ssh/authorized_keys

ADD init.sh /home/$NB_USER/init.sh

ADD .bashrc /home/$NB_USER/.bashrc

# permission tweaking
USER root
RUN chown -R $NB_USER /home/$NB_USER/.ssh
RUN chown -R $NB_USER /home/$NB_USER/.kube
RUN fix-permissions /home/$NB_USER/init.sh
RUN fix-permissions /home/$NB_USER/.bashrc

USER $NB_UID

# JLab user extensions
RUN pip install ipywidgets
#RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build

## debugger
#RUN conda install xeus-python ptvsd -c conda-forge
#RUN jupyter labextension install @jupyterlab/debugger
#RUN jupyter labextension install jupyterlab-kernelspy

## drawio
RUN pip install jupyterlab-drawio

## latex
#RUN pip install jupyterlab_latex && \
#	jupyter labextension install @jupyterlab/latex

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID

