APPNAME=signatumd
#VERSION=$(shell git describe --tags)
VERSION=1.0
NAMESPACE=squbs

build:  
	docker build -t $(NAMESPACE)/$(APPNAME) -t $(NAMESPACE)/$(APPNAME):$(VERSION) .
