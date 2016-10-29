import unittest
import random
import sys
import time
import cProfile
import os

from pyRankingList.cython_trees import BinaryTree, RBTree

class BinaryTreeTest(unittest.TestCase):
	def __init__(self, *args):
		super(BinaryTreeTest, self).__init__(*args)

	def setUp(self):
		pass

	def tearDown(self):
		pass

	def testLen(self):
		bt = BinaryTree()
		N = 1000
		expectedLen = set()
		for i in xrange(N):
			n = random.randint(1, N//100)
			try:
				bt.insert(n, i)
				expectedLen.add(n)
			except KeyError:
				pass

			self.assertEqual(len(bt), len(expectedLen))

		for i in xrange(N):
			n = random.randint(1, N//100)
			try:
				# print 'remove',n
				node = bt.findNode(n)
				bt.removeNode( node)
				expectedLen.remove(n)

			except KeyError:
				pass

			self.assertEqual(len(bt), len(expectedLen))

	def testInsert(self):
		bt = BinaryTree()
		for i in xrange(1000):
			bt.insert(i, i)
			self.assertEqual(len(bt), i+1)

	def testRemove(self):
		N = 1000
		keys = set()
		bt = BinaryTree()
		for i in xrange(N):
			key = random.randint(1, N * 100)

			bt.insert(key, key)
			keys.add(key)

		self.assertEqual(len(keys), len(bt))

		keysCopy = list(keys)
		random.shuffle(keysCopy)
		for key in keysCopy:

			keys.remove(key)

			node = bt.findNode(key)
			bt.removeNode(node)
			
			self.assertEqual(len(bt), len(keys))
			bt.validate()

		bt.validate()

	def testSuccNode(self):
		N = 100000
		t = self.newRandomTree(BinaryTree, N)

		startTravelTime = time.time()

		for i in  xrange(10):
			node = t.findMinNode()
			nodeCount = 0
			lastkey, lastval = node.key, node.value

			while node:
				nodeCount += 1
				# print >>sys.stderr, 'getSucc'
				if not node.moveSucc():
					break

				key, val = node.item
				assert key > lastkey, (key, lastkey)
				lastkey, lastval = key, val

		print 'succ travel tree takes %ss' % (time.time() - startTravelTime)

		self.assertEqual(nodeCount, len(t))

	def testPrevNode(self):
		N = 100000
		t = self.newRandomTree(BinaryTree, N)

		startTravelTime = time.time()

		for i in  xrange(10):
			node = t.findMaxNode()
			nodeCount = 0
			lastkey, lastval = node.key, node.value

			while node:
				nodeCount += 1
				# print >>sys.stderr, 'getSucc'
				if not node.movePrev():
					break

				key, val = node.item
				assert key < lastkey, (key, lastkey)
				lastkey, lastval = key, val

		print >>sys.stderr, 'prev travel tree takes %ss' % (time.time() - startTravelTime)

		self.assertEqual(nodeCount, len(t))

	def testRBTreeBasic(self):
		N = 10000
		t = self.newRandomTree(RBTree, N)
		keys = t.keys()
		# print >>sys.stderr, 'RBTree: len', len(t), 'keys', keys

		random.shuffle(keys)
		for key in keys:
			node = t.findNode(key)
			t.removeNode(node)
			t.validate()

		print 'testRBTree', len(t), t.keys()

	def testRBTreeDeep(self):
		N = 10000
		t = RBTree()
		keys = set()
		REMOVE_PROB = 0.7
		
		def genKey():
			while True:
				k = random.randint(1, N * 100)
				if k not in keys:
					keys.add(k)
					return k
		
		for i in xrange(N):
			key = genKey()
			t.insert(key, 1)
			self.assertEqual(len(t), len(keys))
			t.validate()

			if len(t) > 0 and random.random() < REMOVE_PROB:
				k = random.choice(list(keys)) # key to remove
				node = t.findNode(k)
				t.removeNode(node)
				keys.remove(k)
				t.validate()
				self.assertEqual(len(t), len(keys))
		
	def newRandomTree(self, treeCls, n):
		keys = set()
		t = treeCls()
		for i in xrange(n):
			key  = random.randint(1, n*100)
			while key in keys:
				key  = random.randint(1, n*100)

			keys.add(key)
			t.insert(key, i)
			t.validate()

		self.assertEqual(len(t), n)
		t.validate()
		return t


if __name__ =='__main__':
	unittest.main()
