#!/usr/bin/env bash

set -e

git checkout master
./utility/generateall.sh

echo "Updating C"
git checkout c
git rm -rf include
git rm -rf src
mv build/include include/
mv build/src src/
git add --all include
git add --all src
git commit -am "automatically updated"
git push origin c:c

echo "Updating D"
git checkout d
git rm -rf glad
mv build/glad glad/
git add --all glad
git commit -am "automatically updated"
git push origin d:d

echo "Updating Volt"
git checkout volt
git rm -rf amp
mv build/amp amp/
git add --all amp
git commit -am "automatically updated"
git push origin volt:volt

git checkout master
