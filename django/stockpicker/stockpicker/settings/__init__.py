from .default_settings import *

# Local settings overrides
try:
    from .local_settings import *
except ImportError:
    pass
