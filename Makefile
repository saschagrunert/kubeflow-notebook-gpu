TAG = v1.0.0
IMAGE = quay.io/saschagrunert/kubeflow-notebook-gpu:$(TAG)

all:
	podman build -t $(IMAGE) .

push:
	podman push $(IMAGE)
