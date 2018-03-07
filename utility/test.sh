#!/bin/bash

EXIT_ON_FAILURE=${EXIT_ON_FAILRE:=0}
PRINT_MESSAGE=${PRINT_MESSAGE:=0}
PRINT_ADDITIONAL=${PRINT_ADDITIONAL:=0}

GLAD=${GLAD:="python -m glad"}

TEST_DIRECTORY=${TEST_DIRECTORY:="test"}
TEST_PATTERN=${TEST_PATTERN:="test.*"}

TESTS=${TESTS:=$(find $TEST_DIRECTORY -iname $TEST_PATTERN)}


function run_test {
    local test="$1"

    local glad=$(extract "GLAD" "$test")
    local compile=$(extract "COMPILE" "$test")
    local run=$(extract "RUN" "$test")

    execute $GLAD $glad && \
        execute $compile && \
        execute $run

    return $?
}

function extract {
    local variable="$1"
    local test="$2"

    local variable=$(grep -oP "(?<=$variable: ).*" "$test")
    log_failure $? "Unable to extract variable '$variable'"

    echo "$variable"
}

function execute {
    local _output;
    _output=$(eval $@ 2>&1)
    local status=$?

    log_failure $status "Command '$*' failed with status code $?" "$_output"

    return $status
}

function log_failure {
    local status="$1"
    local message="$2"
    local additional="$3"

    if [ $status -ne 0 ]; then
        if [ $PRINT_MESSAGE -ne 0 ]; then
            echo "$message" >&2
            if [ $PRINT_ADDITIONAL -ne 0 ] && [ -n "$additional" ]; then
                echo "$additional" >&2
            fi
        fi
    fi
}

_tests_total=${#TESTS[@]}
_tests_ran=0
_tests_failed=0

for test in $TESTS; do
    _tests_ran=$((_tests_ran+1))

    echo -n "  -> $test "
    run_test $test

    if [ $? -ne 0 ]; then
        echo "| ✕"
        _tests_failed=$((_tests_failed+1))

        if [ $EXIT_ON_FAILURE -eq 1 ]; then
            exit 1
        fi
    else
        echo "| ✓"
    fi
done

echo
echo "Total tests: $_tests_total, Tests ran: $_tests_ran, Tests failed: $_tests_failed"

