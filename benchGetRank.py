import timeit
import random
from pyRankingList import RankingList


def timeRandomCase(N):
	r = RankingList(limit=100)
	for i in xrange(N):
		uid = str(random.randint(1, 1000))
		r.update( uid, random.randint(1, 1000), None )
		if uid in r:
			r.getRank(uid)

	print 'RankMap hit %d, miss %d' % (r.rankMapHit, r.rankMapMiss)


def timeNormalCase(N):
	scores = {}
	r = RankingList(limit=100)
	for i in xrange(N):
		uid = str(random.randint(1, 1000))
		if uid in scores:
			score = scores[uid] = scores[uid] + random.randint(1,1)
		else:
			score = scores[uid] = random.randint(1, 1000)

		r.update( uid, score, None )
		if uid in r:
			r.getRank(uid)

	print 'RankMap hit %d, miss %d' % (r.rankMapHit, r.rankMapMiss)


if __name__ == '__main__':
	number = 1
	stmt = "timeRandomCase(100000)"
	t = timeit.timeit(stmt, number=number, setup="from __main__ import timeRandomCase")
	print '%s x %d takes %.3f seconds' % (stmt, number, t)

	stmt = "timeNormalCase(100000)"
	t = timeit.timeit(stmt, number=number, setup="from __main__ import timeNormalCase")
	print '%s x %d takes %.3f seconds' % (stmt, number, t)





