from distutils.core import setup
from Cython.Build import cythonize

ext_modules = cythonize(['*.pyx'])

setup(
  name = 'pyRankingList',
  ext_modules = ext_modules,
)
