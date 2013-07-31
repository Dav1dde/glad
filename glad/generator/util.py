import os.path
import os


def enforce(exp, message, exc):
    if not exp:
        raise exc(message)


def makefiledir(path):
    dir = os.path.split(path)[0]
    if not os.path.exists(dir):
        os.makedirs(dir)