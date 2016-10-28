PYFILES = errors.py __init__.py

all:
	python setup.py build_ext --inplace
	cp $(PYFILES) pyRankingList/

test: all
	python test.py

clean:
	rm -rf build
	rm -rf *.so
	rm -rf *~
	rm -rf $(patsubst %.pyx,%.c,$(wildcard *.pyx))
	rm -rf pyRankingList
