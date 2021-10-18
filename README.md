# Simple WASM extension written in Rust

## Prerequisites

 - llvm 
 - lld

### x86 RHEL 8 or FC 33, 34
llvm and lld can be installed with:
```
# yum install llvm lld
```

### s390x RHEL 8 (IBM System Z)  

llvm is available in RPM form in the RHEL repositories, but lld is not. 

You will need to [build llvm from source](https://github.com/llvm/llvm-project) to get the llvm linker lld.

## Steps to build it

To specify which lld llvm linker you will be using, set the environment variable 
```
export RUSTFLAGS="-C linker=wasm-ld"
```
and set in the `.cargo/config.toml` file:
```
[rust]
lld = true
```

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
