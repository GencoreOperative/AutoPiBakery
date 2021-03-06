# Assemble the Auto-Pi-Bakery Docker images
# Usage:
# make         # compile each version of the Docker image
# make publish # Publish the latest version to Docker.io
# make clean   # Clean the local working folder

all: build

# Generated Docker images are tagged using the current Git version
git = $(shell git rev-parse --short HEAD)


# Build each of the supported images.
build: clean build-jessie
	
build-jessie: patches/pibuilder.patch patches/first_run.patch
	docker build -t gencore/auto-pi-bakery-jessie:$(git) .
	docker tag gencore/auto-pi-bakery-jessie:$(git) gencore/auto-pi-bakery-jessie:latest

# Generate patches from the original and modified versions of the files
# The diffs are intermediate files so can be generated by the build process.
# NB: Diff will output 0 for no changes, 1 for changes found and >1 for errors
patches/pibuilder.patch:
	-cd patches && diff pibuilder.sh pibuilder.modified > pibuilder.patch

patches/first_run.patch:
	-cd patches && diff first_run.sh first_run.modified > first_run.patch

# Check that we are logged into Docker before we attempt to push artifacts to
# some other docker repository.
publish:
	@sh utils/docker-login
	@echo "Pushing latest image to Docker"
	docker push gencore/auto-pi-bakery-jessie:$(git)
	docker push gencore/auto-pi-bakery-jessie:latest

.PHONY: clean
clean:
	rm -rf output
	rm -f patches/pibuilder.patch
	rm -f patches/first_run.patch