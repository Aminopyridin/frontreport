VERSION := $(shell git describe --always --tags --abbrev=0 | tail -c +2)
RELEASE := $(shell git describe --always --tags | awk -F- '{ if ($$2) dot="."} END { printf "1%s%s%s%s\n",dot,$$2,dot,$$3}')
VENDOR := "SKB Kontur"
URL := "https://github.com/skbkontur/frontreport"
LICENSE := "BSD"

default: clean prepare test build rpm

clean:
	rm -rf build

prepare:
	go get github.com/kardianos/govendor
	govendor sync
	go get github.com/jteeuwen/go-bindata/...
	go-bindata -prefix "data/" -o "http/bindata.go" -pkg http data/...

test: prepare
	echo "No tests"

build: prepare
	mkdir build
	cd cmd/frontreport && go build -ldflags "-X main.version=$(VERSION)-$(RELEASE)" -o ../../build/frontreport

rpm: clean build
	mkdir -p build/root/usr/bin
	cp build/frontreport build/root/usr/bin/
	fpm -t rpm \
		-s dir \
		--description "CSP/HPKP/StacktraceJS Report Collector" \
		-C build/root \
		--vendor $(VENDOR) \
		--url $(URL) \
		--license $(LICENSE) \
		--name frontreport \
		--version "$(VERSION)" \
		--iteration "$(RELEASE)" \
		-p build
