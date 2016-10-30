from distutils.core import setup
from Cython.Build import cythonize

ext_modules = cythonize(['*.pyx'])

for mod in ext_modules:
	for f in mod.sources:
		if f.endswith('cython_trees.c'):
			mod.sources.append('ctrees.c') # build cython_trees.pyx with ctrees.c
			break 

setup(
  name = 'pyRankingList',
  ext_modules = ext_modules,
  packages = ['pyRankingList'],
  package_dir = {'pyRankingList': 'src'},
)
