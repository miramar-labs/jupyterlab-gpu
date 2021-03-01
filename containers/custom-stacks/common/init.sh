#!/usr/bin/env bash

mkdir fast.ai
pushd fast.ai
# fast.ai course v4
git clone git@github.com:fastai/course-v4.git
pushd course-v4
pip install -r requirements.txt
popd

# fast.ai book
git clone git@github.com:fastai/fastbook.git
popd

# lazyprogrammer
mkdir lp
pushd lp
git clone git@github.com:lazyprogrammer/machine_learning_examples.git
popd

# qiskit tutorials
mkdir Q
pushd Q
git clone git@github.com:Qiskit/qiskit-iqx-tutorials.git
git clone git@github.com:jaygambetta/my-notebooks.git
popd

mkdir Spark
pushd Spark
# scala/spark
git clone git@github.com:deanwampler/JustEnoughScalaForSpark.git
popd

# JupyterLAB demo
git clone git@github.com:jupyterlab/jupyterlab-demo.git

# my AI repo
pushd work
git clone https://github.com/miramar-labs/ai-files.git
popd

# Tips
# 1. using pip as sudo:
#   sudo -H /opt/conda/bin/pip install -U jetson-stats