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

    local did_fail=0

    execute $GLAD $glad && \
        execute $compile && \
        execute $run

    return $?
}

function extract {
    local variable="$1"
    local test="$2"

    local variable=$(grep -oP "(?<=$variable: ).*" "$test")
    assert_success $? "Unable to extract variable '$variable'"

    echo "$variable"
}

function execute {
    local _output;
    _output=$(eval $@ 2>&1)
    local status=$?

    assert_success $status "Command '$*' failed with status code $?" "$_output"

    return $status
}

function assert_success {
    local status="$1"
    local message="$2"
    local additional="$3"

    if [ $status -ne 0 ]; then
        die "$message" "$additional"
    fi
}

function die {
    local message="$1"
    local additional="$2"

    if [ $PRINT_MESSAGE -ne 0 ]; then
        echo "$message" >&2
        if [ $PRINT_ADDITIONAL -ne 0 ] && [ -n "$additional" ]; then
            echo "$additional" >&2
        fi
    fi

    if [ $EXIT_ON_FAILURE -eq 1 ]; then
        exit 1
    fi
}

_tests_total=0
_tests_failed=0

for test in $TESTS; do
    _tests_total=$((_tests_total+1))

    echo -n "  -> $test "
    run_test $test

    if [ $? -ne 0 ]; then
        echo "| ✕"
        _tests_failed=$((_tests_failed+1))
    else
        echo "| ✓"
    fi
done

echo
echo "Total tests $_tests_total, Tests failed $_tests_failed"

