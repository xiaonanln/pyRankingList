
from cython_trees cimport RBTree, TreeNode

cdef class RankingList:

	cdef int seq 
	cdef RBTree tree

	def __cinit__(self):
		print "RankingList.__cinit__"
		self.seq = 0
		self.tree = RBTree()

	def __dealloc__(self):
		print "RankingList.__dealloc__"

	cpdef void update(self, object uid, object score, object info):
		print 'update', uid, score, info
		cdef int seq = self.getNextSeq()
		cdef tuple key = (score, seq)
		cdef tuple val = (uid, info)
		self.tree.insert( key,  val )

	cdef int getNextSeq(self):
		self.seq -= 1
		return self.seq

	def items(self):
		node = self.tree.findMaxNode()
		if node:
			yield (node.key[0], node.value[0], node.value[1])
			while node.movePrev():
				yield (node.key[0], node.value[0], node.value[1])
