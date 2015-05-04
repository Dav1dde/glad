#!/usr/bin/env python
# -*- coding: utf8 -*-

"""
Uses the official Khronos-XML specs to generate a
GL/GLES/EGL/GLX/WGL Loader made for your needs. Glad currently supports
the languages C, D and Volt.

Note: this package might be slightly outdated, for always up to date versions
checkout the GitHub repository: https://github.com/Dav1dde/glad
"""

from setuptools import setup, find_packages


if __name__ == '__main__':
    setup(
        name='glad',
        version='0.1.0a5',
        description='Multi-Language GL/GLES/EGL/GLX/WGL Loader-Generator based on the official specs.',
        long_description=__doc__,
        packages=find_packages(),
        install_requires=[],
        entry_points={
            'console_scripts': [
                'glad = glad.__main__:main'
            ]
        },
        classifiers=[
            'Development Status :: 5 - Production/Stable',
            'Environment :: Console',
            'Intended Audience :: Developers',
            'Intended Audience :: Education',
            'Intended Audience :: Science/Research',
            'License :: OSI Approved :: MIT License',
            'Natural Language :: English',
            'Operating System :: OS Independent',
            'Programming Language :: Python :: 2',
            'Programming Language :: Python :: 2.7',
            'Programming Language :: Python :: 3',
            'Programming Language :: Python :: 3.4',
            'Topic :: Games/Entertainment',
            'Topic :: Multimedia :: Graphics',
            'Topic :: Multimedia :: Graphics :: 3D Rendering',
            'Topic :: Software Development',
            'Topic :: Software Development :: Build Tools',
            'Topic :: Utilities'
        ],
        keywords='opengl glad generator gl wgl egl gles glx',
        author='David Herberth',
        author_email='admin@dav1d.de',
        url='https://github.com/Dav1dde/glad',
        license='MIT',
        platforms='any'
    )
