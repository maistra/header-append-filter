# Simple WASM extension written in Rust

## Steps to build it

Install `rust`, if not already installed:

```sh
$ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Install `wasm32` target, if not already installed:

```sh
$ rustup target add wasm32-unknown-unknown
```

Build the extension:

```sh
$ make build
```

A file named `extension.wasm` was created in the current directory.
