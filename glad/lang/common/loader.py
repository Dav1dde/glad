class BaseLoader(object):
    def __init__(self, apis, disabled=False, local_files=False):
        self.apis = apis
        self.disabled = disabled
        self.local_files = local_files

    def write(self, fobj):
        raise NotImplementedError

    def write_begin_load(self, fobj):
        raise NotImplementedError

    def write_end_load(self, fobj):
        raise NotImplementedError

    def write_find_core(self, fobj):
        raise NotImplementedError

    def write_has_ext(self, fobj):
        raise NotImplementedError

    def write_header(self, fobj):
        raise NotImplementedError

    def write_header_end(self, fobj):
        raise NotImplementedError


class NullLoader(BaseLoader):
    def write_begin_load(self, fobj):
        pass

    def write_end_load(self, fobj):
        pass

    def write_header_end(self, fobj):
        pass

    def write_has_ext(self, fobj):
        pass

    def write(self, fobj):
        pass

    def write_header(self, fobj):
        pass

    def write_find_core(self, fobj):
        pass

    def __getattr__(self, name):
        try:
            return self.__getattribute__(name)
        except AttributeError:
            pass

        def dummy(*args, **kwargs):
            pass
        return dummy

