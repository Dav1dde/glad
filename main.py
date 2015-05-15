from glad.__main__ import main
import warnings

warnings.simplefilter('always', DeprecationWarning)
_message = 'main.py is deprecated, use "python -m glad" instead ' \
           'or install glad via pip, see README.md for more information.'
warnings.warn(_message, DeprecationWarning, stacklevel=1)

main()
