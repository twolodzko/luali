
The code example comes from *The Little Schemer* book by Friedmann and Felleisen (MIT, 1996).

The unit tests are adapted from the code found in the https://github.com/bmitc/the-little-schemer repository.

I used this code to run a benchmark against MIT Scheme:

```shell
$ hyperfine -m 100 --warmup 10 \
   'scheme --quiet < examples/the-little-schemer/run-all.scm' \
   'lua main.lua examples/the-little-schemer/run-all.scm'
Benchmark 1: scheme --quiet < examples/the-little-schemer/run-all.scm
  Time (mean ± σ):     205.3 ms ±   2.7 ms    [User: 161.5 ms, System: 43.8 ms]
  Range (min … max):   201.0 ms … 217.1 ms    100 runs
 
Benchmark 2: lua main.lua examples/the-little-schemer/run-all.scm
  Time (mean ± σ):     129.1 ms ±   4.2 ms    [User: 127.0 ms, System: 2.2 ms]
  Range (min … max):   123.6 ms … 153.2 ms    100 runs
 
Summary
  'lua main.lua examples/the-little-schemer/run-all.scm' ran
    1.59 ± 0.06 times faster than 'scheme --quiet < examples/the-little-schemer/run-all.scm'
```
