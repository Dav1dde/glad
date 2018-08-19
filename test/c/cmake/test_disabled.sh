#!/bin/sh

# GLAD: true
# COMPILE: echo "$(pwd) - $tmp | $test_dir" && cd $tmp && cmake $test_dir
# RUN: ctest --no-compress-output -T Test --verbose
