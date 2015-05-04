#!/usr/bin/env python
# -*- coding: utf8 -*-

from setuptools import setup, find_packages


if __name__ == '__main__':
    setup(
        name='glad',
        version='0.1.0a0',
        packages=find_packages(),
        install_requires=[],
        entry_points={
            'console_scripts': [
                'glad = glad.__main__:main'
            ]
        }
    )
