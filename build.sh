cargo clean && cargo build --target wasm32-wasi --release
mkdir target/wasm32-wasi/optimized
wasm-opt -Os -o target/wasm32-wasi/optimized/argon2-wasi.wasm target/wasm32-wasi/release/argon2-wasi.wasm
cp target/wasm32-wasi/optimized/argon2-wasi.wasm ./bin/argon2-wasi.wasm
