export SHELL := /bin/bash
export REGISTRY := registry.lan.aaroncody.com:5000
export NOCACHE := --no-cache
export PYVER := default
export CUDAVER := nvidia/cuda:11.0-cudnn8-runtime-ubuntu18.04
export TAG := TEST

.PHONY: all
all: notebooks

.PHONY: list
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

.PHONY: clean
clean: clean-sources clean-images clean-dangling
	rm -rf docker-stacks && \
	rm -rf custom-stacks/ihaskell-notebook

.PHONY: clean-sources
clean-sources:
	rm -rf docker-stacks && \
	rm -rf custom-stacks/ihaskell-notebook

.PHONY: clean-images
clean-images:
ifneq  ($(strip $(shell docker images -a -q)),)
	docker rmi -f $(shell docker images -a -q)
endif

.PHONY: clean-dangling
clean-dangling:
ifneq ($(strip $(shell docker images -q --filter "dangling=true")),)
	docker rmi -f $(shell docker images -q --filter "dangling=true")
endif

.PHONY: sourceprep
sourceprep: clean-sources
	git clone git@github.com:jupyter/docker-stacks.git && \
	pushd custom-stacks && \
	git clone git@github.com:jamesdbrock/ihaskell-notebook.git && \
	rm -rf ihaskell-notebook/.git* && \
	popd

.PHONY: get-k8s-config
get-k8s-config:
	rsync -av -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --rsync-path="sudo rsync" aaron@master1:/etc/kubernetes/admin.conf ./custom-stacks/common/admin.conf

.PHONY: wipe-nodes
wipe-nodes:
	pushd ../../cluster/local.esxi && \
	ansible-playbook ../../jup/containers/wipe-nodes.yml && \
	popd

.PHONY: wipe-registry
wipe-registry:
	pushd ../../cluster/local.esxi && \
	ansible-playbook ../../reg/utils/reset-registry-nfs.yml&& \
	popd

.PHONY: rebuild-jlab
rebuild-jlab: undeploy-jlab deploy-jlab

.PHONY: undeploy-jlab
undeploy-jlab:
	pushd ../../cluster/local.esxi && \
	ansible-playbook ../../jup/undeploy.yml && \
	popd

.PHONY: deploy-jlab
deploy-jlab:
	pushd ../../cluster/local.esxi && \
	ansible-playbook ../../jup/deploy.yml && \
	popd

.PHONY: nukeimages
nukeimages: undeploy-jlab wipe-nodes deploy-jlab

.PHONY: nukemypod
nukemypod:
	kubectl -n cluster delete pod jupyter-aaron

.PHONY: watch
watch:
	watch -n1 'docker images'

#------------------------------- Notebooks -----------------------------------------------------------------------
.PHONY: notebooks
notebooks: get-k8s-config base-notebooks minimal-notebooks minimal-ext-notebooks ihaskell-notebooks r-notebooks q-notebooks xeus-cling-notebooks scipy-notebooks datascience-notebooks tensorflow-notebooks \
 pytorch-notebooks tfx-notebooks spark-ext-notebooks pyspark-notebooks all-spark-notebooks
	echo "BUILD notebooks - DONE"

#-------------
.PHONY: base-notebooks
base-notebooks: gpu-base-notebook

.PHONY: gpu-base-notebook
gpu-base-notebook:
	pushd docker-stacks/base-notebook && \
	docker build $(NOCACHE) --build-arg PYTHON_VERSION=$(PYVER) --build-arg BASE_CONTAINER=$(CUDAVER) -t $(REGISTRY)/gpu/base-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/gpu/base-notebook:$(TAG) && \
	popd

#-------------
.PHONY: minimal-notebooks
minimal-notebooks: gpu-minimal-notebook cpu-minimal-notebook

.PHONY: gpu-minimal-notebook
gpu-minimal-notebook: gpu-base-notebook
	pushd docker-stacks/minimal-notebook && \
	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/gpu/base-notebook:$(TAG) -t $(REGISTRY)/gpu/minimal-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/gpu/minimal-notebook:$(TAG) && \
	popd

.PHONY: cpu-minimal-notebook
cpu-minimal-notebook:
	pushd docker-stacks/minimal-notebook && \
	docker build $(NOCACHE) -t $(REGISTRY)/cpu/minimal-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/cpu/minimal-notebook:$(TAG) && \
	popd

#-------------
.PHONY: minimal-ext-notebooks
minimal-ext-notebooks: gpu-minimal-ext-notebook cpu-minimal-ext-notebook

.PHONY: gpu-minimal-ext-notebook
gpu-minimal-ext-notebook: gpu-minimal-notebook
	pushd custom-stacks/common && \
	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/gpu/minimal-notebook:$(TAG) -t $(REGISTRY)/gpu/minimal-ext-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/gpu/minimal-ext-notebook:$(TAG) && \
	popd

.PHONY: cpu-minimal-ext-notebook
cpu-minimal-ext-notebook: cpu-minimal-notebook
	pushd custom-stacks/common && \
	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/cpu/minimal-notebook:$(TAG) -t $(REGISTRY)/cpu/minimal-ext-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/cpu/minimal-ext-notebook:$(TAG) && \
	popd

#-------------
.PHONY: spark-ext-notebooks
spark-ext-notebooks: gpu-spark-ext-notebook cpu-spark-ext-notebook

.PHONY: gpu-spark-ext-notebook
gpu-spark-ext-notebook: gpu-minimal-ext-notebook
	pushd custom-stacks/spark-common && \
	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/gpu/minimal-ext-notebook:$(TAG) -t $(REGISTRY)/gpu/spark-ext-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/gpu/spark-ext-notebook:$(TAG) && \
	popd

.PHONY: cpu-spark-ext-notebook
cpu-spark-ext-notebook: cpu-minimal-ext-notebook
	pushd custom-stacks/spark-common && \
	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/cpu/minimal-ext-notebook:$(TAG) -t $(REGISTRY)/cpu/spark-ext-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/cpu/spark-ext-notebook:$(TAG) && \
	popd

#-------------
.PHONY: r-notebooks
r-notebooks: gpu-r-notebook cpu-r-notebook

.PHONY: gpu-r-notebook
gpu-r-notebook: gpu-minimal-notebook
	pushd docker-stacks/r-notebook && \
	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/gpu/minimal-ext-notebook:$(TAG) -t $(REGISTRY)/gpu/r-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/gpu/r-notebook:$(TAG) && \
	popd

.PHONY: cpu-r-notebook
cpu-r-notebook: cpu-minimal-notebook
	pushd docker-stacks/r-notebook && \
	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/cpu/minimal-ext-notebook:$(TAG) -t $(REGISTRY)/cpu/r-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/cpu/r-notebook:$(TAG) && \
	popd

#-------------
.PHONY: scipy-notebooks
scipy-notebooks: gpu-scipy-notebook cpu-scipy-notebook

.PHONY: gpu-scipy-notebook
gpu-scipy-notebook: gpu-minimal-ext-notebook
	pushd docker-stacks/scipy-notebook && \
	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/gpu/minimal-ext-notebook:$(TAG) -t $(REGISTRY)/gpu/scipy-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/gpu/scipy-notebook:$(TAG) && \
	popd

.PHONY: cpu-scipy-notebook
cpu-scipy-notebook: cpu-minimal-ext-notebook
	pushd docker-stacks/scipy-notebook && \
	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/cpu/minimal-ext-notebook:$(TAG) -t $(REGISTRY)/cpu/scipy-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/cpu/scipy-notebook:$(TAG) && \
	popd

#-------------
.PHONY: datascience-notebooks
datascience-notebooks: gpu-datascience-notebook cpu-datascience-notebook

.PHONY: gpu-datascience-notebook
gpu-datascience-notebook: gpu-scipy-notebook
	pushd docker-stacks/datascience-notebook && \
	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/gpu/scipy-notebook:$(TAG) -t $(REGISTRY)/gpu/datascience-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/gpu/datascience-notebook:$(TAG) && \
	popd

.PHONY: cpu-datascience-notebook
cpu-datascience-notebook: cpu-scipy-notebook
	pushd docker-stacks/datascience-notebook && \
	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/cpu/scipy-notebook:$(TAG) -t $(REGISTRY)/cpu/datascience-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/cpu/datascience-notebook:$(TAG) && \
	popd

#-------------
# runtime gpu cuda/tf issue with 2.4.1 - fixing in custom stacks

#.PHONY: tensorflow-notebooks
#tensorflow-notebooks: gpu-tensorflow-notebook cpu-tensorflow-notebook

#.PHONY: gpu-tensorflow-notebook
#gpu-tensorflow-notebook: gpu-scipy-notebook
#	pushd docker-stacks/tensorflow-notebook && \
#	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/gpu/scipy-notebook:$(TAG) -t $(REGISTRY)/gpu/tensorflow-notebook:$(TAG) -f Dockerfile . && \
#	docker push $(REGISTRY)/gpu/tensorflow-notebook:$(TAG) && \
#	popd

#.PHONY: cpu-tensorflow-notebook
#cpu-tensorflow-notebook: cpu-scipy-notebook
#	pushd docker-stacks/tensorflow-notebook && \
#	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/cpu/scipy-notebook:$(TAG) -t $(REGISTRY)/cpu/tensorflow-notebook:$(TAG) -f Dockerfile . && \
#	docker push $(REGISTRY)/cpu/tensorflow-notebook:$(TAG) && \
#	popd

#-------------
.PHONY: pyspark-notebooks
pyspark-notebooks: gpu-pyspark-notebook cpu-pyspark-notebook

.PHONY: gpu-pyspark-notebook
gpu-pyspark-notebook: gpu-scipy-notebook
	pushd docker-stacks/pyspark-notebook && \
	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/gpu/scipy-notebook:$(TAG) -t $(REGISTRY)/gpu/pyspark-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/gpu/pyspark-notebook:$(TAG) && \
	popd

.PHONY: cpu-pyspark-notebook
cpu-pyspark-notebook: cpu-scipy-notebook
	pushd docker-stacks/pyspark-notebook && \
	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/cpu/scipy-notebook:$(TAG) -t $(REGISTRY)/cpu/pyspark-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/cpu/pyspark-notebook:$(TAG) && \
	popd

#-------------
.PHONY: all-spark-notebooks
all-spark-notebooks: gpu-all-spark-notebook cpu-all-spark-notebook

.PHONY: gpu-all-spark-notebook
gpu-all-spark-notebook: gpu-pyspark-notebook
	pushd docker-stacks/all-spark-notebook && \
	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/gpu/pyspark-notebook:$(TAG) -t $(REGISTRY)/gpu/all-spark-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/gpu/all-spark-notebook:$(TAG) && \
	popd

.PHONY: cpu-all-spark-notebook
cpu-all-spark-notebook: cpu-pyspark-notebook
	pushd docker-stacks/all-spark-notebook && \
	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/cpu/pyspark-notebook:$(TAG) -t $(REGISTRY)/cpu/all-spark-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/cpu/all-spark-notebook:$(TAG) && \
	popd

#-------------
# CUSTOM STACKS
#-------------

.PHONY: pytorch-notebooks
pytorch-notebooks: gpu-pytorch-notebook cpu-pytorch-notebook

.PHONY: gpu-pytorch-notebook
gpu-pytorch-notebook: gpu-scipy-notebook
	pushd custom-stacks/pytorch-notebook && \
	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/gpu/scipy-notebook:$(TAG) -t $(REGISTRY)/gpu/pytorch-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/gpu/pytorch-notebook:$(TAG) && \
	popd

.PHONY: cpu-pytorch-notebook
cpu-pytorch-notebook: cpu-scipy-notebook
	pushd custom-stacks/pytorch-notebook && \
	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/cpu/scipy-notebook:$(TAG) -t $(REGISTRY)/cpu/pytorch-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/cpu/pytorch-notebook:$(TAG) && \
	popd

#-------------

.PHONY: tfx-notebooks
tfx-notebooks: gpu-tfx-notebook cpu-tfx-notebook

.PHONY: gpu-tfx-notebook
gpu-tfx-notebook: gpu-tensorflow-notebook
	pushd custom-stacks/tfx-notebook && \
	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/gpu/tensorflow-notebook:$(TAG) -t $(REGISTRY)/gpu/tfx-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/gpu/tfx-notebook:$(TAG) && \
	popd

.PHONY: cpu-tfx-notebook
cpu-tfx-notebook: cpu-tensorflow-notebook
	pushd custom-stacks/tfx-notebook && \
	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/cpu/tensorflow-notebook:$(TAG) -t $(REGISTRY)/cpu/tfx-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/cpu/tfx-notebook:$(TAG) && \
	popd

#-------------

.PHONY: xeus-cling-notebooks
xeus-cling-notebooks: gpu-xeus-cling-notebook cpu-xeus-cling-notebook

.PHONY: gpu-xeus-cling-notebook
gpu-xeus-cling-notebook: gpu-minimal-ext-notebook
	pushd custom-stacks/cpp-notebook && \
	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/gpu/minimal-ext-notebook:$(TAG) -t $(REGISTRY)/gpu/cpp-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/gpu/cpp-notebook:$(TAG) && \
	popd

.PHONY: cpu-xeus-cling-notebook
cpu-xeus-cling-notebook: cpu-minimal-ext-notebook
	pushd custom-stacks/cpp-notebook && \
	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/cpu/minimal-ext-notebook:$(TAG) -t $(REGISTRY)/cpu/cpp-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/cpu/cpp-notebook:$(TAG) && \
	popd

#-------------
.PHONY: ihaskell-notebooks
ihaskell-notebooks: gpu-ihaskell-notebook cpu-ihaskell-notebook

.PHONY: gpu-ihaskell-notebook
gpu-ihaskell-notebook: gpu-minimal-ext-notebook
	pushd custom-stacks/ihaskell-notebook && \
	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/gpu/minimal-ext-notebook:$(TAG) -t $(REGISTRY)/gpu/haskell-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/gpu/haskell-notebook:$(TAG) && \
	popd

.PHONY: cpu-ihaskell-notebook
cpu-ihaskell-notebook: cpu-minimal-ext-notebook
	pushd custom-stacks/ihaskell-notebook && \
	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/cpu/minimal-ext-notebook:$(TAG) -t $(REGISTRY)/cpu/haskell-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/cpu/haskell-notebook:$(TAG) && \
	popd

#-------------
.PHONY: q-notebooks
scipy-q-notebooks: gpu-q-notebook cpu-q-notebook

.PHONY: gpu-q-notebook
gpu-q-notebook: gpu-minimal-ext-notebook
	pushd custom-stacks/q-notebook && \
	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/gpu/minimal-ext-notebook:$(TAG) -t $(REGISTRY)/gpu/q-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/gpu/q-notebook:$(TAG) && \
	popd

.PHONY: cpu-q-notebook
cpu-q-notebook: cpu-minimal-ext-notebook
	pushd custom-stacks/q-notebook && \
	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/cpu/minimal-ext-notebook:$(TAG) -t $(REGISTRY)/cpu/q-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/cpu/q-notebook:$(TAG) && \
	popd

#-------------
.PHONY: tensorflow-notebooks
tensorflow-notebooks: gpu-tensorflow-notebook cpu-tensorflow-notebook

.PHONY: gpu-tensorflow-notebook
gpu-tensorflow-notebook: gpu-scipy-notebook
	pushd custom-stacks/tensorflow-notebook && \
	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/gpu/scipy-notebook:$(TAG) -t $(REGISTRY)/gpu/tensorflow-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/gpu/tensorflow-notebook:$(TAG) && \
	popd

.PHONY: cpu-tensorflow-notebook
cpu-tensorflow-notebook: cpu-scipy-notebook
	pushd custom-stacks/tensorflow-notebook && \
	docker build $(NOCACHE) --build-arg BASE_CONTAINER=$(REGISTRY)/cpu/scipy-notebook:$(TAG) -t $(REGISTRY)/cpu/tensorflow-notebook:$(TAG) -f Dockerfile . && \
	docker push $(REGISTRY)/cpu/tensorflow-notebook:$(TAG) && \
	popd
#------------------------------- JLab RUN TARGETS ----------------------------------------------------------------------
# GPU

.PHONY: run-gpu-r-notebook
run-gpu-r-notebook:
	docker run --rm -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v "$PWD":/home/jovyan/work $(REGISTRY)/gpu/r-notebook:$(TAG)

.PHONY: run-gpu-scipy-notebook
run-gpu-scipy-notebook:
	docker run --rm -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v "$PWD":/home/jovyan/work $(REGISTRY)/gpu/scipy-notebook:$(TAG)

.PHONY: run-gpu-q-notebook
run-gpu-q-notebook:
	docker run --rm -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v "$PWD":/home/jovyan/work $(REGISTRY)/gpu/q-notebook:$(TAG)

.PHONY: run-gpu-datascience-notebook
run-gpu-datascience-notebook:
	docker run --rm -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v "$PWD":/home/jovyan/work $(REGISTRY)/gpu/datascience-notebook:$(TAG)

.PHONY: run-gpu-tensorflow-notebook
run-gpu-tensorflow-notebook:
	docker run --rm -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v "$PWD":/home/jovyan/work $(REGISTRY)/gpu/tensorflow-notebook:$(TAG)

.PHONY: run-gpu-tfx-notebook
run-gpu-tfx-notebook:
	docker run --rm -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v "$PWD":/home/jovyan/work $(REGISTRY)/gpu/tfx-notebook:$(TAG)

.PHONY: run-gpu-pyspark-notebook
run-gpu-pyspark-notebook:
	docker run --rm -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v "$PWD":/home/jovyan/work $(REGISTRY)/gpu/pyspark-notebook:$(TAG)

.PHONY: run-gpu-all-spark-notebook
run-gpu-all-spark-notebook:
	docker run --rm -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v "$PWD":/home/jovyan/work $(REGISTRY)/gpu/all-spark-notebook:$(TAG)

.PHONY: run-gpu-ihaskell-notebook
run-gpu-ihaskell-notebook:
	docker run --rm -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v "$PWD":/home/jovyan/work $(REGISTRY)/gpu/haskell-notebook:$(TAG)

.PHONY: run-gpu-pytorch-notebook
run-gpu-pytorch-notebook:
	docker run --rm -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v "$PWD":/home/jovyan/work $(REGISTRY)/gpu/pytorch-notebook:$(TAG)

.PHONY: run-gpu-xeus-cling-notebook
run-gpu-xeus-cling-notebook:
	docker run --rm -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v "$PWD":/home/jovyan/work $(REGISTRY)/gpu/cpp-notebook:$(TAG)

# CPU

.PHONY: run-cpu-r-notebook
run-cpu-r-notebook:
	docker run --rm -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v "$PWD":/home/jovyan/work $(REGISTRY)/cpu/r-notebook:$(TAG)

.PHONY: run-cpu-scipy-notebook
run-cpu-scipy-notebook:
	docker run --rm -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v "$PWD":/home/jovyan/work $(REGISTRY)/cpu/scipy-notebook:$(TAG)

.PHONY: run-cpu-q-notebook
run-cpu-q-notebook:
	docker run --rm -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v "$PWD":/home/jovyan/work $(REGISTRY)/cpu/q-notebook:$(TAG)

.PHONY: run-cpu-datascience-notebook
run-cpu-datascience-notebook:
	docker run --rm -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v "$PWD":/home/jovyan/work $(REGISTRY)/cpu/datascience-notebook:$(TAG)

.PHONY: run-cpu-tensorflow-notebook
run-cpu-tensorflow-notebook:
	docker run --rm -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v "$PWD":/home/jovyan/work $(REGISTRY)/cpu/tensorflow-notebook:$(TAG)

.PHONY: run-cpu-tfx-notebook
run-cpu-tfx-notebook:
	docker run --rm -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v "$PWD":/home/jovyan/work $(REGISTRY)/cpu/tfx-notebook:$(TAG)

.PHONY: run-cpu-pyspark-notebook
run-cpu-pyspark-notebook:
	docker run --rm -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v "$PWD":/home/jovyan/work $(REGISTRY)/cpu/pyspark-notebook:$(TAG)

.PHONY: run-cpu-all-spark-notebook
run-cpu-all-spark-notebook:
	docker run --rm -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v "$PWD":/home/jovyan/work $(REGISTRY)/cpu/all-spark-notebook:$(TAG)

.PHONY: run-cpu-ihaskell-notebook
run-cpu-ihaskell-notebook:
	docker run --rm -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v "$PWD":/home/jovyan/work $(REGISTRY)/cpu/haskell-notebook:$(TAG)

.PHONY: run-cpu-pytorch-notebook
run-cpu-pytorch-notebook:
	docker run --rm -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v "$PWD":/home/jovyan/work $(REGISTRY)/cpu/pytorch-notebook:$(TAG)

.PHONY: run-cpu-xeus-cling-notebook
run-cpu-xeus-cling-notebook:
	docker run --rm -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v "$PWD":/home/jovyan/work $(REGISTRY)/cpu/cpp-notebook:$(TAG)

