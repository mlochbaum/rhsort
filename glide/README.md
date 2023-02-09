Shim for benchmarking glidesort, a fast stable comparison sort in Rust.
It has similar performance characteristics to fluxsort: it benchmarks
substantially slower (~20%) on my CPU and just slightly slower on newer
ones. This includes overhead for panic safety: the author estimates this
at 10-15% and it wouldn't apply to a C version. I've decided not to use
it in published benchmarks because of the extra complication in setting
up Rust and the fact that it's not directly comparable to C.

To benchmark, starting in repository root directory:

```sh
# Nightly (this line, +nightly below) isn't required but is currently faster
rustup update nightly
# cargo fetches the package
cd glide && cargo +nightly build --release && cd ..

gcc -O3 -D GLIDESORT -D NOTEST bench.c -Lglide/target/release -lglide
LD_LIBRARY_PATH=glide/target/release ./a.out l > res/r_glide.txt 

# rand.svg plus glidesort
images/line.bqn res/r_{flux,wolf,ska_,glide,rh}.txt > images/rand_glide.svg
```

This last line assumes the other res/r_\*.txt files exist. See
instructions for rand.svg in the main README.
