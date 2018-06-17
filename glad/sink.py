import collections
import logging


class Sink(object):
    def info(self, message, exc=None):
        raise NotImplementedError

    def warning(self, message, exc=None):
        raise NotImplementedError

    def error(self, message, exc=None):
        raise NotImplementedError


class NullSink(Sink):
    def info(self, message, exc=None):
        pass

    def warning(self, message, exc=None):
        pass

    def error(self, message, exc=None):
        pass


class LoggingSink(Sink):
    _DEFAULT_LOGGER = logging.getLogger(__name__)

    def __init__(self, name=None, logger=None):
        self.logger = logger
        if self.logger is None and name is not None:
            self.logger = logging.getLogger(name)
        if self.logger is None:
            self.logger = self._DEFAULT_LOGGER

    def info(self, message, exc=None):
        self.logger.info(message)

    def warning(self, message, exc=None):
        self.logger.warning(message)

    def error(self, message, exc=None):
        self.logger.error(message)


Message = collections.namedtuple('Message', ['type', 'content', 'exc'])


class CollectingSink(Sink):
    def __init__(self):
        self.messages = list()

    def info(self, message, exc=None):
        self.messages.append(Message('info', message, exc))

    def warning(self, message, exc=None):
        self.messages.append(Message('warning', message, exc))

    def error(self, message, exc=None):
        self.messages.append(Message('error', message, exc))

    @property
    def infos(self):
        return [m for m in self.messages if m.type == 'info']

    @property
    def warnings(self):
        return [m for m in self.messages if m.type == 'warning']

    @property
    def errors(self):
        return [m for m in self.messages if m.type == 'error']

