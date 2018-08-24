Tests
=====

Directory containing a small collection of unit tests for glad. Unit testing glad
is rather hard to do since it would require many hand crafted test specifications.

So most of the testing is done using integration tests which can be found in
[`/test`](../test) directory.


## Execution

Run with:

    python -m unittest discover tests/

or:

    nosetests
