#!/bin/bash

hyperfine -m 100 --warmup 1 \
    'lua main.lua examples/fibo.scm' \
    'lua main.lua examples/fibo-tco.scm'
