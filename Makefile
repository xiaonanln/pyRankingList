all:
	python setup.py build_ext --inplace && cp pyRankingList/*.so ./

clean:
	rm -rf build
	rm -rf *.so
	rm -rf *~
	rm -rf $(patsubst %.pyx,%.c,$(wildcard *.pyx))
	rm -rf pyRankingList
