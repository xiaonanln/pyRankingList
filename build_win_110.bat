set VS90COMNTOOLS=%VS110COMNTOOLS%

python setup.py build_ext --inplace || pause
cp errors.py __init__.py pyRankingList/