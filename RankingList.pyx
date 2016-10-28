
from cython_trees cimport RBTree, TreeNode

cdef class RankingList:

	cdef int limit
	cdef int seq 
	cdef RBTree tree
	cdef dict rankMap
	cdef dict uid2TreeKey
	cdef tuple minKey
	cdef readonly int size

	def __cinit__(self, int limit=-1):
		self.seq = 0
		self.tree = RBTree()
		self.limit = limit if limit > 0 else -1
		self.size = 0
		self.uid2TreeKey = {}
		self.rankMap = None
		self.minKey = None

	cpdef void update(self, object uid, object score, object info):
		cdef int seq = self.getNextSeq()
		cdef tuple key = (score, seq)
		cdef tuple val = (uid, info)
		
		cdef TreeNode minItem, nextMinItem

		cdef tuple oldKey = self.uid2TreeKey.get(uid)

		if oldKey is None:
			# uid not in rank
			if self.full():
				if key < self.minKey:
					# this update won't change the ranking, at all
					return 

				# ranking is full, need to remove the item with smallest score
				minItem = self.tree.findMinNode()
				assert minItem.key == self.minKey, "min key in tree (%s) should be equal to minKey (%s)" % (minItem.key, self.minKey)
				nextMinItem = minItem.getSuccNode()
				minItem.remove()
				self.tree.insert(key,  val)

				if nextMinItem is None:
					self.minKey = key
				else:
					self.minKey = nextMinItem.key
					if key < self.minKey: self.minKey = key
			else:
				# rank is not full, simply insert the new item
				self.tree.insert( key,  val )
				self.size += 1
				if key < self.minKey: self.minKey = key
		else:
			# uid already in rank, just update it
			self.tree.findNode(oldKey).remove()
			self.tree.insert( key,  val )

			if key < self.minKey: self.minKey = key

		self.uid2TreeKey[uid] = key

		self.outdateRankMap()

	cpdef bint full(self):
		return self.limit != -1 and self.size >= self.limit

	cpdef void updateInfo(self, object uid, object newInfo):
		cdef tuple key = self.uid2TreeKey[uid]
		cdef TreeNode node = self.tree.findNode(key)
		node.remove()
		self.tree.insert( key, (uid, newInfo) )
		
	cpdef object getInfo(self, object uid):
		cdef tuple key = self.uid2TreeKey[uid]
		cdef TreeNode node = self.tree.findNode(key)
		return node.value[1]

	cdef int getNextSeq(self):
		self.seq -= 1
		return self.seq

	def items(self):
		return list(self.iteritems())

	def iteritems(self):
		node = self.tree.findMaxNode()
		if node:
			(score, seq), (uid, info) = node.key, node.value
			yield uid, score, info
			while node.movePrev():
				(score, seq), (uid, info) = node.key, node.value
				yield uid, score, info
		
	def top(self, N):
		for uid, score, info in self.iteritems():
			if N > 0:
				yield uid, score, info
				N -= 1
			else:
				break

	cpdef int getRank(self, object uid) except 0:
		if self.rankMap is None:
			self.genRankMap()

		return self.rankMap[uid]
	
	cdef genRankMap(self):
		print 'genRankMap ...'

		cdef dict rankMap = {}
		cdef int rank = 1
		for uid, score, info in self.iteritems():
			rankMap[uid] = rank
			rank += 1

		self.rankMap = rankMap

	cdef outdateRankMap(self):
		self.rankMap = None

	cpdef object getRankScore(self, object uid):
		cdef tuple key = self.uid2TreeKey[uid]
		return key[0]

	def __contains__(self, object uid):
		return uid in self.uid2TreeKey

