IMAGE_TAG ?= docker-dmarc-srg
TEST_ADDR ?= dmarc-srg
# All: linux/amd64,linux/arm64,linux/riscv64,linux/ppc64le,linux/s390x,linux/386,linux/mips64le,linux/mips64,linux/arm/v7,linux/arm/v6
PLATFORM ?= linux/amd64

ACTION ?= load
PROGRESS_MODE ?= plain

.PHONY: docker-build docker-test run-test cleanup-test test

all: docker-build docker-test

docker-build:
	# https://github.com/docker/buildx#building
	docker buildx build \
		--build-arg VCS_REF="$(shell git rev-parse HEAD)" \
		--build-arg BUILD_DATE="$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")" \
		--tag $(IMAGE_TAG) \
		--progress $(PROGRESS_MODE) \
		--platform $(PLATFORM) \
		--pull \
		--$(ACTION) \
		./docker

docker-test: test

test: run-test cleanup-test

run-test:
	TEST_ADDR="${TEST_ADDR}" \
	IMAGE_TAG="${IMAGE_TAG}" \
	DMARC_SRG_UI_PASSWORD="public" \
	# Random port maybe free ?
	DMARC_SRG_HTTP_ADDRESS="8912" \
	docker-compose -f docker-compose-latest.test.yml up --exit-code-from=sut --abort-on-container-exit

cleanup-test:
	@echo "Stopping and removing the container"
	TEST_ADDR="${TEST_ADDR}" \
	IMAGE_TAG="${IMAGE_TAG}" \
	DMARC_SRG_UI_PASSWORD="public" \
	# Random port maybe free ?
	DMARC_SRG_HTTP_ADDRESS="8912" \
	docker-compose -f docker-compose-latest.test.yml down
