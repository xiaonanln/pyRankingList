import unittest
import random
from pyRankingList import RankingList

class TestRankingList(unittest.TestCase):

	def testCreate(self):
		r = RankingList()

	def testUpdate(self):
		r = RankingList()
		r.update(1, 100, [1, 2, 3])
		r.update(2, 60, [2, 3, 4])
		for item in r.items():
			print item

		r.update(1, 50, [])
		self.assertEquals(r.size, 2)

		print list(r.top(100))

	def testGetRank(self):
		r = RankingList()
		r.update(10, 100, [1, 2, 3])
		r.update(20, 60, [2, 3, 4])
		self.assertEquals(r.getRank(10), 1)
		self.assertEquals(r.getRank(20), 2)
		r.update(30, 200, [])
		self.assertEquals(r.getRank(30), 1)
		self.assertEquals(r.getRank(10), 2)
		self.assertEquals(r.getRank(20), 3)

	def testGetRankScore(self):
		r = RankingList()
		r.update(10, 100, [1, 2, 3])
		r.update(20, 60, [2, 3, 4])

		self.assertTrue(10 in r)
		self.assertTrue(20 in r)
		self.assertFalse(100 in r)

		self.assertEquals(r.getRankScore(10), 100)

	def testSetGetInfo(self):
		r = RankingList()
		r.update(1, 1, 123)
		self.assertEquals(r.getInfo(1), 123)
		
		r.updateInfo(1, 333)
		self.assertEquals(r.getInfo(1), 333)

	def testPressure(self):
		r = RankingList()
		real = {}

		for i in xrange(100000):
			uid = random.randint(1, 10000)
			score = random.randint(1, 10000)

			r.update(uid, score, i)
			real[uid] = (score, -i)

		real = sorted(real.items(), key=lambda (uid, key): key)
		for i, x in enumerate(real):
			rank = len(real) - i
			uid = x[0]
			score = x[1][0]

			self.assertTrue(uid in r)
			self.assertEquals(r.getRank(uid), rank)
			self.assertEquals(r.getRankScore(uid), score)
		
if __name__ == '__main__':
	unittest.main()
