PYFILES = errors.py __init__.py

all:
	python setup.py build_ext 

test: all
	python test.py
	python benchGetRank.py

clean:
	rm -rf build
	rm -rf *.so
	rm -rf *~
	rm -rf $(patsubst %.pyx,%.c,$(wildcard *.pyx))
	rm -rf pyRankingList
