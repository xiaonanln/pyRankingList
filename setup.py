from distutils.core import setup
from Cython.Build import cythonize

ext_modules = cythonize(['*.pyx'])

setup(
  name = 'ftimer',
  ext_modules = ext_modules,
)
