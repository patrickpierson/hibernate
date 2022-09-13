default: release

APP="castai/hibernate"
TAG_LATEST=$(APP):latest
#TAG_LATEST=$(APP):test1

gke:
	(cd ./hack/gke && terraform init && terraform apply -auto-approve)

eks:
	(cd ./hack/eks && terraform init && terraform apply -target module.vpc -auto-approve && terraform apply -target module.eks -auto-approve && terraform apply -auto-approve)

aks:
	(cd ./hack/aks && terraform init && terraform apply -auto-approve)

kind:
	(cd ./hack/kind && sh run.sh)

pull:
	docker pull $(TAG_LATEST)

build:
	@echo "==> Building hibernate container"
	docker build --cache-from $(TAG_LATEST) --platform linux/amd64 -t $(TAG_LATEST) .

publish:
	@echo "==> pushing to docker hub"
	docker push $(TAG_LATEST)

release: pull
release: build
release: publish

deploy:
	kubectl apply -f deploy.yaml