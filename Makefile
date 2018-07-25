IMAGE = connectitnet/ansible-for-docker

build:
		docker build -t ${IMAGE} .

push: build
		docker push ${IMAGE}