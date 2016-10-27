all:
	python setup.py build_ext --inplace

clean:
	rm -rf build
	rm -rf *.so
	rm -rf *~
	rm -rf $(patsubst %.pyx,%.c,$(wildcard *.pyx))
