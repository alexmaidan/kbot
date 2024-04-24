APP=$(shell basename $(shell git remote get-url origin))
REGESTRY=alexmaidan
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux #linux darwin windows
TARGETARCH=arm64 #amd64 arm64 arm

format:
	gofmt -s -w ./

get:
	go get

lint:
	golint

test:
	go test -v
	
build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/alexmaidan/kbot/cmd.appVersion=${VERSION}

image:
	docker build . -t ${REGESTRY}/${APP}:${VERSION}-${TARGETARCH}

push:
	docker push ${REGESTRY}/${APP}:${VERSION}-${TARGETARCH}

dive: image
	IMG1=$$(docker images -q | head -n 1); \
	CI=true docker run -ti --rm -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive --ci --lowestEfficiency=0.99 $${IMG1}; \
	IMG2=$$(docker images -q | sed -n 2p); \
	docker rmi $${IMG1}; \
	docker rmi $${IMG2}

clean:
	rm -rf kbot