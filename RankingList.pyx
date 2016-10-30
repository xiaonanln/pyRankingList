
from cython_trees cimport RBTree as TreeImpl
from cython_trees cimport TreeNode

cdef class RankingList:

	cdef int limit
	cdef int seq 
	cdef TreeImpl tree
	cdef dict rankMap
	cdef dict uid2TreeKey
	cdef tuple minKey
	cdef readonly int size
	cdef readonly int rankMapHit, rankMapMiss

	def __cinit__(self, int limit=-1):
		self.seq = 0
		self.tree = TreeImpl()
		self.limit = limit if limit > 0 else -1
		self.size = 0
		self.uid2TreeKey = {}
		self.rankMap = None
		self.minKey = None

	cpdef void update(self, object uid, object score, object info) except *:
		# print 'update', uid, score, self.size
		cdef int seq = self.getNextSeq()
		cdef tuple key = (score, seq)
		cdef tuple val = (uid, info)
		
		cdef TreeNode oldNode, minItem, nextMinItem, succNode, prevNode

		cdef tuple oldKey = self.uid2TreeKey.get(uid)
		cdef bint rankNotChanged = 0

		if oldKey is not None:
			# uid already in rank, just update it
			# goes here in most cases
			oldNode = self.tree.findNode(oldKey)
			succNode = oldNode.getSuccNode()
			prevNode = oldNode.getPrevNode()

			oldNode.remove()
			assert succNode is None or succNode.key[0] >= oldKey[0]
			assert prevNode is None or prevNode.key[0] <= oldKey[0]

			self.tree.insert( key,  val )

			if self.minKey is None or key < self.minKey: self.minKey = key

			rankNotChanged = (prevNode is None or prevNode.key[0] < score) and (succNode is None or succNode.key[0] >= score)
		else:
			# uid not in rank
			if self.full():
				#if key < self.minKey:
				#	# this update won't change the ranking, at all
				#	return 

				# ranking is full, need to remove the item with smallest score
				minItem = self.tree.findMinNode()
				if key < minItem.key:
					return 

				# assert minItem.key == self.minKey, "min key in tree (%s) should be equal to minKey (%s)" % (minItem.key, self.minKey)
				nextMinItem = minItem.getSuccNode()
				
				del self.uid2TreeKey[minItem.value[0]]
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
				if self.minKey is None or key < self.minKey: self.minKey = key

		self.uid2TreeKey[uid] = key

		if not rankNotChanged:
			self.outdateRankMap()

#		if self.size > 0:
#			assert self.minKey == self.tree.findMinNode().key, (self.size, self.minKey, self.tree.findMinNode().item, list(self.items()))


	cpdef bint full(self):
		return self.limit != -1 and self.size >= self.limit

	cpdef void updateInfo(self, object uid, object newInfo) except *:
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
			self.rankMapMiss += 1
			self.genRankMap()
		else:
			self.rankMapHit += 1

		return self.rankMap[uid]
	
	cdef genRankMap(self):
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

