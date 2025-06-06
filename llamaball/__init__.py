from importlib import import_module

# Simple shim to maintain backwards compatibility
module = import_module("llamaline")

for attr in module.__all__:
    globals()[attr] = getattr(module, attr)

__all__ = module.__all__
__version__ = module.__version__
