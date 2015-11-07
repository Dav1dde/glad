#!/usr/bin/env python

"""
Glad
----

Glad uses the official Khronos-XML specs to generate a
GL/GLES/EGL/GLX/WGL Loader made for your needs.

Checkout the GitHub repository: https://github.com/Dav1dde/glad
"""

from setuptools import setup, find_packages
import ast
import re


# Thanks flask: https://github.com/mitsuhiko/flask/blob/master/setup.py
_version_re = re.compile(r'__version__\s+=\s+(.*)')

with open('glad/__init__.py', 'rb') as f:
    version = str(ast.literal_eval(_version_re.search(
        f.read().decode('utf-8')).group(1)))


if __name__ == '__main__':
    setup(
        name='glad',
        version=version,
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
