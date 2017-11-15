#!/bin/bash -e

if [ -z "$1" ]; then
    echo "No version supplied"
    exit 1
fi

VERSION="$1"
VERSION_PYTHON="__version__ = '$VERSION'"

OLD_VERSION=$(python2 -c "import glad; print glad.__version__")

echo "Old Version: $OLD_VERSION"
echo "New Version: $VERSION"
echo

read -p "Do you want to update to version $VERSION ($VERSION_PYTHON) [y/n]: " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

echo -e "\n$VERSION_PYTHON\n" > glad/__init__.py

git commit -am "setup: Bumped version: $VERSION."
git tag "v$VERSION"

rm -r build/
rm -r dist/

python2 setup.py sdist bdist_wheel
twine upload dist/*
