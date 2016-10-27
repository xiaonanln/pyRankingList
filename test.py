import unittest
from RankingList import RankingList

class TestRankingList(unittest.TestCase):

	def testCreate(self):
		r = RankingList()

	def testUpdate(self):
		r = RankingList()
		r.update(1, 100, [1, 2, 3])
		r.update(2, 60, [2, 3, 4])
		for item in r.items():
			print item

if __name__ == '__main__':
	unittest.main()
