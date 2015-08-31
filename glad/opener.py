from contextlib import closing
import logging
import sys

if sys.version_info >= (3, 0):
    _is_py3 = True
    from urllib.request import build_opener, ContentTooShortError
else:
    _is_py3 = False
    from urllib2 import build_opener
    from urllib import FancyURLopener


logger = logging.getLogger('glad.opener')


def build_urllib_opener(user_agent, *args, **kwargs):
    if _is_py3:
        return None

    class UrllibURLOpener(FancyURLopener):
        version = user_agent
    return UrllibURLOpener(*args, **kwargs)


def _urlretrieve_with_opener(opener, url, filename, data=None):
    if not _is_py3:
        raise SyntaxError('Only call this in Python 3 code.')

    # borrowed from the original implementation at urllib.request.urlretrieve.
    with closing(opener.open(url, data=data)) as src:
        headers = src.info()

        with open(filename, 'wb') as dest:
            result = filename, headers
            bs = 1024*8
            size = -1
            read = 0
            blocknum = 0
            if "content-length" in headers:
                size = int(headers["Content-Length"])

            while True:
                block = src.read(bs)
                if not block:
                    break
                read += len(block)
                dest.write(block)
                blocknum += 1

    if size >= 0 and read < size:
        raise ContentTooShortError(
            'retrieval incomplete: got only %i out of %i bytes'
            % (read, size), result)

    return result


class URLOpener(object):
    """
    Class to download/find Khronos related files, like
    the official specs and khrplatform.h.

    Can also be used to download files, exists mainly because of
    Python 2 and Python 3 incompatibilities.
    """
    def __init__(self, user_agent='Mozilla/5.0'):
        # the urllib2/urllib.request opener
        self.opener = build_opener()
        self.opener.addheaders = [('User-agent', user_agent)]

        # the urllib opener (Python 2 only)
        self.opener2 = build_urllib_opener(user_agent)

    def urlopen(self, url, data=None, *args, **kwargs):
        """
        Same as urllib2.urlopen or urllib.request.urlopen,
        the only difference is that it links to the internal opener.
        """
        logger.info('opening: \'%s\'', url)

        if data is None:
            return self.opener.open(url)

        return self.opener.open(url, data)

    def urlretrieve(self, url, filename, data=None):
        """
        Similar to urllib.urlretrieve or urllib.request.urlretrieve
        only that *filname* is required.

        :param url: URL to download.
        :param filename: Filename to save the content to.
        :param data: Valid URL-encoded data.
        :return: Tuple containing path and headers.
        """
        logger.info('saving: \'%s\' to \'%s\'', url, filename)

        if _is_py3:
            return _urlretrieve_with_opener(self.opener, url, filename, data=data)

        return self.opener2.retrieve(url, filename, data=data)

    # just a singleton helper:
    _default = None

    @classmethod
    def default(cls):
        if cls._default is None:
            cls._default = cls()

        return cls._default
