from .default_settings import *  # noqa: F401,F403

# Local settings overrides
try:
    from .local_settings import *  # noqa: F401,F403
except ImportError:
    pass
