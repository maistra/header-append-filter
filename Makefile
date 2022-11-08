VERSION = 2.4
HUB ?= quay.io/maistra-dev
CARGO_HOME =

build: oidc.wasm

oidc.wasm:
	cargo build --target wasm32-unknown-unknown --release
	cp target/wasm32-unknown-unknown/release/header_append_filter.wasm ./plugin.wasm

.PHONY: clean
clean:
	rm -f plugin.wasm
	rm -rf build

.PHONY: container
container: clean build
	mkdir build
	cp plugin.wasm build/
	cd build && docker build -t ${HUB}/header-append-filter:${VERSION} . -f ../container/Dockerfile

container.push: container
	docker push ${HUB}/header-append-filter:${VERSION}

.PHONY: lint
# TODO: Add linter for rust code
lint:
	find . -name '*.sh' -print0 | xargs -0 -r shellcheck

.PHONY: test
test: build
	./tests/run-envoy.sh
