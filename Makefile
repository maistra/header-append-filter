VERSION = 2.1
HUB ?= quay.io/maistra-dev

build: oidc.wasm

oidc.wasm:
	cargo build --target wasm32-unknown-unknown --release
	cp target/wasm32-unknown-unknown/release/header_append_filter.wasm ./extension.wasm

.PHONY: clean
clean:
	rm extension.wasm || true
	rm -r build || true

.PHONY: container
container: clean build
	mkdir build
	cp container/manifest.yaml build/
	cp extension.wasm build/
	cd build && docker build -t ${HUB}/header-append-filter:${VERSION} . -f ../container/Dockerfile

container.push: container
	docker push ${HUB}/header-append-filter:${VERSION}
