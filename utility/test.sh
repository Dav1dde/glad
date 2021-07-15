#!/bin/bash

EXIT_ON_FAILURE=${EXIT_ON_FAILURE:=0}
PRINT_MESSAGE=${PRINT_MESSAGE:=0}

PYTHON=${PYTHON:="python"}
GLAD_ARGS=${GLAD_ARGS:="--reproducible"}
GLAD=${GLAD:="$PYTHON -m glad ${GLAD_ARGS}"}

_GCC=${_GCC:="gcc"}
_MINGW_GCC=${_MINGW_GCC:="x86_64-w64-mingw32-gcc"}
_GCC_FLAGS="-Wall -Wextra -Werror -Wsign-conversion -Wcast-qual -Wstrict-prototypes -ansi -pedantic"

GCC=${GCC:="$_GCC $_GCC_FLAGS"}
MINGW_GCC=${MINGW_GCC:="$_MINGW_GCC $_GCC_FLAGS"}

WINE=${WINE:="wine"}

TEST_TMP=$(realpath ${TEST_TMP:="build"})

TEST_DIRECTORY=${TEST_DIRECTORY:="test"}
TEST_PATTERN=${TEST_PATTERN:="test.*"}

TESTS=(${TESTS:=$(find "${TEST_DIRECTORY}" -iname "${TEST_PATTERN}" | sort)})

TEST_REPORT_ENABLED=${TEST_REPORT_ENABLED:=1}
TEST_REPORT=${TEST_REPORT:="test-report.xml"}


function run_test {
    local test="$1"

    local glad=$(extract "GLAD" "$test")
    local compile=$(extract "COMPILE" "$test")
    local run=$(extract "RUN" "$test")

    rm -rf "${TEST_TMP}"
    mkdir -p "${TEST_TMP}"

    local time=$(date +%s)

    local wd=$(pwd)

    local output;
    output=$({
        execute ${glad} && \
            execute ${compile} && \
            execute ${run}
    } 2>& 1)
    local status=$?

    time=$(($(date +%s) - ${time}))

    cd "$wd"

    log_failure "${status}" "${output}"
    report_test "${test}" "${status}" "${time}" "${output}"

    return ${status}
}

function report_start {
    if [ ${TEST_REPORT_ENABLED} -eq 0 ]; then
        return
    fi

    echo '<?xml version="1.0" encoding="UTF-8"?>' > ${TEST_REPORT}
    echo '<testsuite>' >> ${TEST_REPORT}
}

function report_test {
    if [ ${TEST_REPORT_ENABLED} -eq 0 ]; then
        return
    fi

    local test=${1#*/}
    local status="$2"
    local time="$3"
    local output=$(echo "$4" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g')

    local class_name=${test%%/*}
    local test_name_with_suffix=${test#*/}
    local test_name=${test_name_with_suffix%/*}

    echo "    <testcase name=\"${test_name//\//.}\" classname=\"${class_name}\" time=\"${time}\">" >> ${TEST_REPORT}
    if [ $status -ne 0 ]; then
        echo "        <failure />" >> ${TEST_REPORT}
    fi
    echo "        <system-out>${output}</system-out>" >> ${TEST_REPORT}
    echo "    </testcase>" >> ${TEST_REPORT}
}

function report_end {
    if [ ${TEST_REPORT_ENABLED} -eq 0 ]; then
        return
    fi

    echo '</testsuite>' >> ${TEST_REPORT}
}

function extract {
    local variable="$1"
    local test="$2"

    local content;
    content=$(grep -oP "(?<=$variable: ).*" "$test")

    log_failure $? "Unable to extract variable '$variable'"

    echo "$content"
}

function execute {
    # define variables for use in test
    local tmp="$TEST_TMP"
    local test_dir="$(dirname ${test})"

    eval $@

    return $?
}

function log_failure {
    local status="$1"
    local message="$2"

    if [ $status -ne 0 ]; then
        if [ $PRINT_MESSAGE -ne 0 ]; then
            echo
            echo "$message" >&2
            echo
        fi
    fi
}


_tests_total=${#TESTS[@]}
_tests_ran=0
_tests_failed=0

report_start

for test in "${TESTS[@]}"; do
    _tests_ran=$((_tests_ran+1))

    echo -n "  🡒 $test "
    test=$(realpath $test)
    run_test $test

    if [ $? -ne 0 ]; then
        echo "| ✕"
        _tests_failed=$((_tests_failed+1))

        if [ $EXIT_ON_FAILURE -eq 1 ]; then
            report_end
            exit 1
        fi
    else
        echo "| ✓"
    fi
done

report_end

echo
echo "Total tests: $_tests_total, Tests ran: $_tests_ran, Tests failed: $_tests_failed"

if [ $_tests_failed -gt 0 ]; then
    exit 1
fi
