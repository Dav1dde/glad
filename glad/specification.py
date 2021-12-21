from glad.parse import Specification, Require


class EGL(Specification):
    DISPLAY_NAME = 'EGL'

    API = 'https://raw.githubusercontent.com/KhronosGroup/EGL-Registry/main/api/'
    NAME = 'egl'

    def protections(self, symbol, api=None, profile=None, feature_set=None):
        return list()


class GL(Specification):
    DISPLAY_NAME = 'OpenGL'

    API = 'https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/main/xml/'
    NAME = 'gl'

    def _magic_require(self, api, profile):
        require = Specification._magic_require(self, api, profile)

        magic_blacklist = (
            'stddef', 'khrplatform', 'inttypes',  # gl.xml
        )
        requirements = [r for r in require.requirements if r not in magic_blacklist]
        return Require(api, profile, requirements)

    def protections(self, symbol, api=None, profile=None, feature_set=None):
        return list()


class GLX(Specification):
    DISPLAY_NAME = 'GLX'

    API = 'https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/main/xml/'
    NAME = 'glx'

    def protections(self, symbol, api=None, profile=None, feature_set=None):
        return list()


class WGL(Specification):
    DISPLAY_NAME = 'WGL'

    API = 'https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/main/xml/'
    NAME = 'wgl'

    def protections(self, symbol, api=None, profile=None, feature_set=None):
        return list()


class VK(Specification):
    DISPLAY_NAME = 'Vulkan'

    API = 'https://raw.githubusercontent.com/KhronosGroup/Vulkan-Docs/main/xml/'
    NAME = 'vk'

    def _magic_require(self, api, profile):
        # magic_categories = (
        #     'define', 'basetype', 'handle'
        # )
        #
        # requirements = [name for name, types in self.types.items()
        #                 if any(t.api in (None, api) and t.category in magic_categories for t in types)]
        #
        # return Require(api, profile, requirements)
        return None

    def _magic_are_enums_blacklisted(self, enums_element):
        # blacklist everything that has a type
        return enums_element.get('type') in ('enum', 'bitmask')
