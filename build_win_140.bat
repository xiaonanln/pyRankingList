set VS90COMNTOOLS=%VS140COMNTOOLS%

python setup.py build_ext --inplace || pause
cp errors.py __init__.py pyRankingList/