#!/bin/bash -e

if [ -z "$1" ]; then
    echo "No version supplied"
    exit 1
fi

VERSION="$1"
VERSION_PYTHON="__version__ = '${VERSION}'"

OLD_VERSION=$(python -c "import glad; print(glad.__version__)")

echo "Old Version: $OLD_VERSION"
echo "New Version: $VERSION"
echo

if [ "$VERSION" == "$OLD_VERSION" ]
then
    echo "Version equals the old version"
    exit 1
fi

echo "Python: $VERSION_PYTHON"
read -p "Do you want to update to version $VERSION? [y/n]: " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Aborted"
    exit 1
fi


echo -e "\n$VERSION_PYTHON\n" > glad/__init__.py

git commit -am "setup: Bumped version: $VERSION."
git tag "v$VERSION"

rm -rf build/
rm -rf dist/

python -m build
twine upload dist/*

