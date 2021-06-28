PROJECT_DIR?=$(shell pwd)
PROJECT_BIN_DIR?=$(PROJECT_DIR)/bin
PROTOTOOL?=$(PROJECT_BIN_DIR)/prototool
GENERATED_DIR?=$(PROJECT_DIR)/pkg/generated
VENDOR_PB?=$(PROJECT_DIR)/vendor.pb

prototool-install:
	mkdir -p $(PROJECT_BIN_DIR)
	curl -sSL https://github.com/uber/prototool/releases/download/v1.8.0/prototool-$$(uname -s)-$$(uname -m) -o $(PROTOTOOL)
	chmod +x $(PROTOTOOL)
	$(PROTOTOOL) version

	GOBIN=$(PROJECT_BIN_DIR) go install github.com/gogo/protobuf/protoc-gen-gofast@latest
	GOBIN=$(PROJECT_BIN_DIR) go install github.com/utrack/clay/v2/cmd/protoc-gen-goclay@latest

clean:
	rm -rf vendor
	rm -rf vendor.pb

proto-dependencies: clean
	mkdir -p $(VENDOR_PB)/google/api
	cd $(VENDOR_PB) && curl -sSL https://raw.githubusercontent.com/googleapis/googleapis/master/google/api/annotations.proto > google/api/annotations.proto
	cd $(VENDOR_PB) && curl -sSL https://raw.githubusercontent.com/googleapis/googleapis/master/google/api/http.proto > google/api/http.proto

generate:
	cd api/ && protoc --proto_path=./ --proto_path=$(VENDOR_PB) --plugin=protoc-gen-gofast=$(PROJECT_BIN_DIR)/protoc-gen-gofast \
	--gofast_out=$(GENERATED_DIR)/. *.proto

