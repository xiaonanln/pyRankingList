
cdef class RankingList:

	def __cinit__(self):
		print "RankingList.__cinit__"
		pass

	def __dealloc__(self):
		print "RankingList.__dealloc__"

	cpdef void update(self, str uid, object score, object info):
		print 'update', uid, score, info

