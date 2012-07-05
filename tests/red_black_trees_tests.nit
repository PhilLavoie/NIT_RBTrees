import tests
import red_black_trees
import algos
import iterators

class RBTreeTests
	super Tests

	init() do		
	end

	redef fun test_all() do
		test_set
		test_multiset
		test_map
		test_multimap
	end
	
	fun test_set() do
		var tree = new TreeSet[ Int ]
#		test_insertions
	end
	
	fun test_multiset() do
		var mset =  new TreeMultiSet[ Int ]
		test_insertions( mset )
#		test_removals( mset )
		test_size( mset )
#		test_retrievals( mset )
	end
	
	fun test_map() do
	
	end
	
	fun test_multimap() do
	
	end

	fun test_size( tree: RBTree[ Int, Int ] ) do
		print "testing size"
		tree.clear
		assert_true( tree.size == 0, "empty tree has a size of {tree.size}" )
		tree.insert( 0 )
		assert_true( tree.size == 1, "one element tree has a size of {tree.size}" )
		tree.remove_at( tree.find( 0 ) )
		assert_true( tree.size == 0, "empty tree after removal has a size of {tree.size}" )
		random_inserts( tree, 0 , 100 )
		assert_true( tree.size == 100, "100 elements tree has a size of {tree.size}" )
		random_removals( tree, 20, 70 )
		assert_true( tree.size == 50, "50 elements tree after 50 removals have size of {tree.size}" )
		random_removals( tree, 0, 20 )
		random_removals( tree, 70, 100 )
		assert_true( tree.size == 0, "empty tree after 50 removals have size of {tree.size}" )
	end

	fun test_insertions( tree: RBTree[ Int, Int ] ) do
		print "testing insertions"
		var expected_result = new Array[ Int ].with_capacity( 100 )
		var reverse_exp_res = new Array[ Int ].with_capacity( 100 )
		for i in [ 0 .. 100 [ do
			expected_result[ i ] = i
			reverse_exp_res[ i ] = 99 - i
		end
		var validator = new RBTreeValidator( tree )
		validator.validate.assert_valid( "empty tree invalid" )
		forward_inserts( tree, 0, 100 )
		validator.validate.assert_valid( "tree after forward insertions invalid" )
		test_equals( expected_result.iterator, tree.iterator )
		test_equals( reverse_exp_res.iterator, tree.reverse_iterator )
		tree.clear
		validator.validate.assert_valid( "cleared tree invalid" )
		backward_inserts( tree, 0, 100 )
		validator.validate.assert_valid( "tree after backward insertions invalid" )
		test_equals( expected_result.iterator, tree.iterator )
		test_equals( reverse_exp_res.iterator, tree.reverse_iterator )
		tree.clear
		forward_inserts( tree, 0, 50 )
		backward_inserts( tree, 50, 100 )
		validator.validate.assert_valid( "tree after mixed insertions invalid" )
		test_equals( expected_result.iterator, tree.iterator )
		test_equals( reverse_exp_res.iterator, tree.reverse_iterator )
		tree.clear
		random_inserts( tree, 0, 100 )
		validator.validate.assert_valid( "invalid tree after random insertions")
		test_equals( expected_result.iterator, tree.iterator )
		test_equals( reverse_exp_res.iterator, tree.reverse_iterator )

		#Test with duplicates.
		expected_result = new Array[ Int ].with_capacity( 200 )
		reverse_exp_res = new Array[ Int ].with_capacity( 200 )
		for i in [ 0 .. 200 [ do
			expected_result[ i ] = i / 2
			reverse_exp_res[ i ] = 99 - ( i / 2 )
		end
		tree.clear
		random_inserts( tree, 0, 100 )
		random_inserts( tree, 0, 100 )
		validator.validate.assert_valid( "invalid tree after duplicate random insertions")
		test_equals( expected_result.iterator, tree.iterator )
		test_equals( reverse_exp_res.iterator, tree.reverse_iterator )

	end

#	fun test_removals() do
#		print "testing removals"
#		self.tree.clear
#		self.tree.remove_at( self.tree.find( 50 ) )
#		self.validator.validate.assert_valid( "invalid tree after removal on empty tree" )

#		self.tree.insert( 50 )
#		self.tree.remove_at( self.tree.find( 50 ) )
#		assert_true( self.tree.is_empty, "adding and removing one element results in an unempty tree" )
#		self.validator.validate.assert_valid( "adding and removing one element produces invalid tree" )
#		self.tree.insert( 50 )
#		self.tree.remove_at( self.tree.find( 500 ) )
#		assert_false( self.tree.is_empty, "removing an unknown element on a one element tree produces an empty tree" )
#		self.validator.validate.assert_valid( "one element tree after false removal is invalid" )

#		var first_half = new Array[ Int ].with_capacity( 50 )
#		for i in [ 0 .. 50[ do
#			first_half[ i ] = i
#		end
#		var r_first_half = first_half.reversed
#		var second_half = new Array[ Int ].with_capacity( 50 )
#		for i in [ 0 .. 50[ do
#			second_half[ i ] = i + 50
#		end
#		var r_second_half = second_half.reversed

#		self.tree.clear
#		forward_inserts( 0, 100 )
#		forward_removals( 0, 50 )
#		self.validator.validate.assert_valid( "forward removals on first half produces invalid tree" )
#		test_equals( second_half.iterator, self.tree.iterator )
#		test_equals( r_second_half.iterator, self.tree.reverse_iterator )
#		random_inserts( 0, 50 )
#		backward_removals( 50, 100 )
#		self.validator.validate.assert_valid( "backward removals on second half produces invalid tree" )
#		test_equals( first_half.iterator, self.tree.iterator )
#		test_equals( r_first_half.iterator, self.tree.reverse_iterator )
#		self.tree.clear
#		backward_inserts( 0, 100 )
#		random_removals( 0, 50 )
#		self.validator.validate.assert_valid( "random removals on first half produces invalid tree" )
#		test_equals( second_half.iterator, self.tree.iterator )
#		test_equals( r_second_half.iterator, self.tree.reverse_iterator )
#		random_removals( 50, 200 )
#		self.validator.validate.assert_valid( "removing the second half and invalid elements produces an invalid tree" )
#		assert_true( self.tree.is_empty, "removing all elements and beyond produces un empty tree" )

#		self.tree.clear
#		random_inserts( 0, 100 )
#		random_removals( 20, 70 )
#		self.validator.validate.assert_valid( "invalid tree after random removals at non edge points" )
#		random_removals( 0, 20 )
#		self.validator.validate.assert_valid( "invalid tree after random removals of first 20 points" )
#		random_removals( 70, 100 )
#		self.validator.validate.assert_valid( "invalid tree after random removals of last 30 points" )
#		assert_true( self.tree.is_empty, "unempty tree after random removals of all elements" )
#	end

#	fun test_retrievals() do
#		print "testing retrievals"
#		var algos = new Algos
#		self.tree.clear
#		assert_false( self.tree.has( 50 ), "empty tree has value 50" )
#		var iter = self.tree.find( 50 )
#		assert_false( iter.is_ok, "retrieving in an empty tree returns a valid iterator" )
#		self.tree.insert( 50 )
#		iter = self.tree.find( 50 )
#		assert_true( iter.is_ok, "retrieving the only element in a tree returns an invalid iterator" )
#		assert_true( iter.item == 50, "retrieve the only element, 50, in a tree returns an iterator on {iter.item}" )
#		var count = algos.count( iter, 50, new ComparatorEquals[ Int, Int ]( self.tree.comparator ) )
#		assert_true( count == 1, "single element iterator returns a count of {count}" )

#		self.tree.clear
#		random_inserts( 0, 100 )
#		iter = self.tree.find( 50 )
#		assert_true( iter.item == 50, "retrieving 50 returned an iterator on {iter.item}" )
#		same_inserts( 50, 19 )
#		self.validator.validate.assert_valid( "invalid tree after the insertion of 19 duplicates" )

#		iter = self.tree.floor( 50 )
#		assert_true( iter.item == 50, "retrieving 50 on 20 duplicates returned an iterator on {iter.item}" )
#		count = algos.count( iter, 50, new ComparatorEquals[ Int, Int ]( self.tree.comparator ) )
#		assert_true( self.tree.size == 119, "expected 119 elements in the tree but size returned {self.tree.size}" )
#		assert_true( count == 20, "counting the element on the iterator at 50 returns {count} when expecting 20" )

#		self.tree.clear
#		same_inserts( 0, 2 )
#		same_inserts( 100, 1 )
#		same_inserts( 50, 5 )
#		iter = self.tree.floor( 50 )
#		assert_true( iter.item == 50, "retrieving 50 on 4 duplicates returned an iterator on {iter.item}" )
#		count = algos.count( iter, 50, new ComparatorEquals[ Int, Int ]( self.tree.comparator ) )
#		assert_true( count == 5, "counting the element on the iterator at 50 returns {count} when expecting 5" )
#	end

	private fun test_equals( exp_res_iter: Iterator[ Int ], eff_res_iter: Iterator[ Int ] ) do
		var algos = new Algos()
		var exp_res = new List[ Int ]
		while exp_res_iter.is_ok do
			exp_res.push( exp_res_iter.item )
			exp_res_iter.next
		end
		var eff_res = new List[ Int ]
		while eff_res_iter.is_ok do
			eff_res.push( eff_res_iter.item )
			eff_res_iter.next
		end
		assert_true( 
			algos.equals( exp_res.iterator, eff_res.iterator ), 
			"Test equals failure\n" + "Expected result: " + exp_res.join( ", " ) + "\nEffective result: " + eff_res.join( ", " )		
		)
	end

	private fun forward_inserts( tree: RBTree[ Int, Int ], min: Int, max: Int ) do
		for i in [ min .. max [ do
			tree.insert( i )
		end
	end

	private fun forward_removals( tree: RBTree[ Int, Int ], min: Int, max: Int ) do
		for i in [ min .. max [ do
			tree.remove_at( tree.find( i ) )
		end
	end

	private fun backward_inserts( tree: RBTree[ Int, Int ], min: Int, max: Int ) do
		var i = max - 1
		while min <= i do
			tree.insert( i )
			i -= 1
		end
	end

	private fun backward_removals( tree: RBTree[ Int, Int ], min: Int, max: Int ) do
		var i = max - 1
		while min <= i do
			tree.remove_at( tree.find( i ) )
			i -= 1
		end
	end

	private fun same_inserts( tree: RBTree[ Int, Int ], value: Int, times: Int ) do 
		for i in [ 1 .. times ] do
			tree.insert( value )
		end
	end

	private fun same_removals( tree: RBTree[ Int, Int ], value: Int, times: Int ) do 
		for i in [ 1 .. times ] do
			tree.remove_at( tree.find( value ) )
		end
	end


	private fun random_inserts( tree: RBTree[ Int, Int ], min: Int, max: Int ) do
		var count = max - min
		var table = new Array[ Int ].with_capacity( count )
		for i in [ 0 .. count [ do
			table[ i ] = i + min
		end
		while not table.is_empty do
			var random_idx = count.rand
			tree.insert( table[ random_idx ] )
			table.remove_at( random_idx )
			count -= 1
		end
	end

	private fun random_removals( tree: RBTree[ Int, Int ], min: Int, max: Int ) do
		var count = max - min
		var table = new Array[ Int ].with_capacity( count )
		for i in [ 0 .. count [ do
			table[ i ] = i + min
		end
		while not table.is_empty do
			var random_idx = count.rand
			tree.remove_at( tree.find( table[ random_idx ] ) )
			table.remove_at( random_idx )
			count -= 1
		end
	end
end

var tests = new RBTreeTests()
tests.test_all
