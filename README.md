# argon2-wasi

This wraps the Rust crate [`argon2`](https://crates.io/crates/argon2) in a very simple WASI (or commandline) compatible program.

Compatible with [`workerd`](https://github.com/cloudflare/workerd) / CloudFlare Workers' [WASI support](https://blog.cloudflare.com/announcing-wasi-on-workers/). You need to run the worker in unbounded mode for it to not time out.

[`bcrypt-wasi`](https://github.com/auth70/bcrypt-wasi) provides an identical API for bcrypt.

## Usage

Simple example:

```ts
import { WASI } from "@cloudflare/workers-wasi";
// @ts-ignore TS2307: Cannot find module './argon2-wasi.wasm'
import argon2 from "./argon2-wasi.wasm";

export async function invoke(args: string[]) {
  const stdout = new TransformStream();
  const stderr = new TransformStream();
  const wasi = new WASI({
    args: ["argon2-wasi.wasm", ...args],
    stdout: stdout.writable,
    stderr: stderr.writable,
  });
  const instance = new WebAssembly.Instance(argon2, {
    wasi_snapshot_preview1: wasi.wasiImport,
  });
  const promise = wasi.start(instance);
  const errors = stderr.readable.getReader().read();
  const ret = stdout.readable.getReader().read();
  const [errorsStream, resultStream, _] = await Promise.all([errors, ret, promise]);
  const errorsValue = new TextDecoder().decode(errorsStream.value);
  if (errorsValue) {
    throw new Error(errorsValue);
  }
  const retValue = new TextDecoder().decode(resultStream.value);
  return retValue.trim();
}

export async function argon2Hash(password: string): Promise<string> {
  return await invoke(["hash", password]);
}

export async function argon2Verify(password: string, hash: string): Promise<boolean> {
  return (await invoke(["verify", password, hash])) === "true";
}
```

Then just use `await argon2Hash('somepwd');` or `await argon2Verify('somepwd', '$argon2id$v..')`

## License

Same license as for the `argon2` crate; licensed under either of:

 * [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)
 * [MIT license](http://opensource.org/licenses/MIT)

at your option.

