import tests
import red_black_trees
import algos
import iterators
import functions

#Order integers such that odds come first.
#When both compared values have the same oddity, then
#the natural ordering is returned.
class OddFirstComparator
	super Comparator[ Int, Int ]
	redef fun call( lhs, rhs ) do
		if lhs == rhs then return 0
		#rhs and lhs are now different
		#If lhs is odd
		if not lhs % 2 == 0 then
			#if lhs and rhs are odd and rhs is lower, than lhs is higher.
			if not rhs % 2 == 0 and rhs < lhs then return 1
			#Otherwise, lhs is lower
			return -1		
		end
		#lhs is even.
		#If rhs is even and higher, then lhs is lower.
		if rhs % 2 == 0 and lhs < rhs then
			return -1
		end
		#Otherwise lhs is higher 
		return 1
	end
end

#Grouping of common functions for all tests on red black trees.
#A subclass should EXTEND every function and not just overwrite it
#(redefine, but at some point call super). In other words, the tests
#provided by this class make no assumptions regarding the ability
#of the underlying tree to support duplicate values. It just
#offers basic test cases (ex: testing insertion just verifies that
#insertion works, but makes no attempt to insert duplicates).
abstract class RBTreeBaseTests
	super Tests	
	
	#This type is for generalizing the methods only.
	#In fact, it should either be an Int or a MapEntry[ Int, Something ]
	type Element: Object
	#This is designed to be an Int regardless of the tree used.
	type Key: Object
	
	#Entry point for tests. Launches all tests and prints an informative
	#statement before each test.
	redef fun test_all() do
		print "insertions"
		test_insertions
		print "removals"
		test_removals
		print "retrievals"
		test_retrievals		
		print "length"
		test_length
		print "with other comparator"
		test_other_comparator
	end
	
	#Test basic facilities using a custom comparator.
	fun test_other_comparator do
		use_comparator( new OddFirstComparator )
		clear
		var expected_result = new Array[ Element ].filled_with( -1, 100 )
		for i in [ 0 .. 100 [ do
			if i % 2 == 1 then
				expected_result[ i / 2 ]  = make_element( i )
			else
				expected_result[ ( i / 2 ) + 50 ] = make_element( i )
			end
		end
		var reverse_exp_res = expected_result.reversed
		random_inserts( 0, 100 )
		validate( "invalid tree after 100 random insertions using a custom comparator" )
		test_equals( expected_result.iterator, iterator )
		test_equals( reverse_exp_res.iterator, reverse_iterator )
		#At this point, we assume that the ordering works correctly, meaning
		#the lower semantic is used appropriately.
		#Removals and retrievals, however, additionally use the equals semantics 
		#of the comparator, therefore we assume we only have to test one of them.
		#We'll use the retrievals because it is easier to implement.
		var iter = find( 50 )
		assert_true( iter.is_ok, "cannot retrieve 50" )
		assert_true( comparator.call( extract_key( iter.item ), 50 ) == 0, "retrieving 50 returned {iter.item}" )
		iter = floor( 100 )
		assert_true( iter.is_ok, "cannot retrieve floor of 100" )
		assert_true( comparator.call( extract_key( iter.item ), 98 ) == 0, "retrieving floor of 100 returned {iter.item}" )
		iter = floor( 101 )
		assert_true( iter.is_ok, "cannot retrieve floor of 101" )
		assert_true( comparator.call( extract_key( iter.item ), 99 ) == 0, "retrieving floor of 101 returned {iter.item}" )
		iter = ceiling( -2 )
		assert_true( iter.is_ok, "cannot retrieve ceiling of -2" )
		assert_true( comparator.call( extract_key( iter.item ), 0 ) == 0, "retrieving ceiling of -2 returned {iter.item}" )
		iter = ceiling( -1 )
		assert_true( iter.is_ok, "cannot retrieve ceiling of -1" )
		assert_true( comparator.call( extract_key( iter.item ), 1 ) == 0, "retrieving ceiling of -1 returned {iter.item}" )
		iter = lowest()
		assert_true( iter.is_ok, "cannot retrieve lowest" )
		assert_true( comparator.call( extract_key( iter.item ), 1 ) == 0, "retrieving lowest returned {iter.item}" )
		iter = highest()
		assert_true( iter.is_ok, "cannot retrieve highest" )
		assert_true( comparator.call( extract_key( iter.item ), 98 ) == 0, "retrieving lowest returned {iter.item}" )		
	end
	
	#Test basic removal facilities.
	fun test_removals() do
		clear
		validate( "invalid tree after clearing the initial tree" )
		remove( 50 )
		validate( "invalid tree after removal on empty tree" )
		insert( make_element( 50 ) )
		remove( 50 )
		assert_true( is_empty, "adding and removing one element results in an unempty tree" )
		validate( "adding and removing one element produces invalid tree" )
		insert( make_element( 50 ) )
		remove( 500 )
		assert_false( is_empty, "removing an unknown element on a one element tree produces an empty tree" )
		validate( "one element tree after false removal is invalid" )

		var first_half = new Array[ Element ].with_capacity( 50 )
		for i in [ 0 .. 50[ do
			first_half[ i ] = make_element( i )
		end
		var r_first_half = first_half.reversed
		var second_half = new Array[ Element ].with_capacity( 50 )
		for i in [ 0 .. 50 [ do
			second_half[ i ] = make_element( i + 50 )
		end
		var r_second_half = second_half.reversed

		clear
		forward_inserts( 0, 100 )
		forward_removals( 0, 50 )
		validate( "forward removals on first half produces invalid tree" )
		test_equals( second_half.iterator, iterator )
		test_equals( r_second_half.iterator, reverse_iterator )
		random_inserts( 0, 50 )
		backward_removals( 50, 100 )
		validate( "backward removals on second half produces invalid tree" )
		test_equals( first_half.iterator, iterator )
		test_equals( r_first_half.iterator, reverse_iterator )
		
		clear
		backward_inserts( 0, 100 )
		random_removals( 0, 50 )
		validate( "random removals on first half produces invalid tree" )
		test_equals( second_half.iterator, iterator )
		test_equals( r_second_half.iterator, reverse_iterator )
		random_removals( 50, 200 )
		validate( "removing the second half and invalid elements produces an invalid tree" )
		assert_true( is_empty, "removing all elements and beyond produces un empty tree" )

		clear
		random_inserts( 0, 100 )
		random_removals( 20, 70 )
		validate( "invalid tree after random removals at non edge points" )
		random_removals( 0, 20 )
		validate( "invalid tree after random removals of first 20 elements" )
		random_removals( 70, 100 )
		validate( "invalid tree after random removals of last 30 elements" )
		assert_true( is_empty, "unempty tree after random removals of all elements" )
		clear
		validate( "invalid tree after clearing on emtpy tree" )
			
		#Testing the remove_at feature when removing a group
		clear
		random_inserts( 0, 100 )
		var iter = lowest()
		assert_true( iter.is_ok, "could not retrieve lowest" )
		#If it does not work, this will either hang or finish too early.
		while iter.is_ok do
			remove_at( iter )
		end	
		assert_true( is_empty, "tree of size {length} after the removal of every element" )	
		random_inserts( 0, 100 )
		var riter = highest().reverse
		assert_true( riter.is_ok, "could not retrieve lowest" )
		#If it does not work, this will either hang or finish too early.
		while riter.is_ok do
			remove_at( riter )
		end	
		assert_true( is_empty, "tree of size {length} after the reverse removal of every element" )
	end

	#Test basic retrievals facilities.
	fun test_retrievals() do
		clear
		assert_false( has( 50 ), "empty tree has value 50" )
		var iter = find( 50 )
		assert_false( iter.is_ok, "retrieving in an empty tree returns a valid iterator" )
		iter = floor( 50 )
		assert_false( iter.is_ok, "empty tree has floor of 50" )
		iter = ceiling( 50 )
		assert_false( iter.is_ok, "empty tree has ceiling of 50" )
		iter = lowest
		assert_false( iter.is_ok, "empty tree has lowest" )
		iter = highest
		assert_false( iter.is_ok, "empty tree has highest" )
		
		insert( make_element( 50 ) )
		iter = find( 50 )
		assert_true( iter.is_ok, "retrieving the only element in a tree returns an invalid iterator" )
		assert_true( comparator.call( extract_key( iter.item ), 50 ) == 0, "retrieve the only element, 50, in a tree returns an iterator on {iter.item}" )
		#The has test is only going to be used once.
		#We assume that if find works, has works.
		assert_true( has( 50 ), "a tree with element 50 returns false for has" )

		clear
		random_inserts( 0, 100 )
		iter = find( 50 )
		assert_true( iter.is_ok, "cannot retrieve 50" )
		assert_true( comparator.call( extract_key( iter.item ), 50 ) == 0, "retrieving 50 returned an iterator on {iter.item}" )
		iter = floor( 50 )
		assert_true( iter.is_ok, "cannot retrieve floor of 50" )
		assert_true( comparator.call( extract_key( iter.item ), 50 ) == 0, "retrieving floor of 50 returned an iterator on {iter.item}" )		
		iter = ceiling( 50 )
		assert_true( iter.is_ok, "cannot retrieve  ceiling 50" )		
		assert_true( comparator.call( extract_key( iter.item ), 50 ) == 0, "retrieving floor of 50 returned an iterator on {iter.item}" )		
		iter.next
		assert_true( comparator.call( extract_key( iter.item ), 51 ) == 0, "next of 50 is {iter.item}" )
		iter.previous
		iter.previous
		assert_true( comparator.call( extract_key( iter.item ), 49 ) == 0, "previous of 50 is {iter.item}" )
		iter = ceiling( -1 )
		assert_true( iter.is_ok, "cannot retrieve ceiling of -1" )
		assert_true( comparator.call( extract_key( iter.item ), 0 ) == 0, "retrieving ceiling of -1 returned {iter.item}" )
		iter = floor( 100 )
		assert_true( iter.is_ok, "cannot retrieve floor of 100" )
		assert_true( comparator.call( extract_key( iter.item ), 99 ) == 0, "retrieving floor of 100 returned {iter.item}" )
		iter = lowest()
		assert_true( iter.is_ok, "cannot retrieve lowest" )
		assert_true( comparator.call( extract_key( iter.item ), 0 ) == 0, "retrieving lowest returned {iter.item}" )
		iter = highest()
		assert_true( iter.is_ok, "cannot retrieve highest" )
		assert_true( comparator.call( extract_key( iter.item ), 99 ) == 0, "retrieving lowest returned {iter.item}" )	
		
		remove( 50 )		
		iter = find( 50 )
		assert_false( iter.is_ok, "retrieving removed 50 returns a valid iterator" )
		iter = floor( 50 )
		assert_true( iter.is_ok, "cannot retrieve floor of removed 50" )
		assert_true( comparator.call( extract_key( iter.item ), 49 ) == 0, "retrieving the floor of removed 50 returned an iterator on {iter.item}" )
		iter = ceiling( 50 )
		assert_true( iter.is_ok, "cannot retrieve ceiling of removed 50" )		
		assert_true( comparator.call( extract_key( iter.item ), 51 ) == 0, "retrieving the ceiling of removed 50 returned an iterator on {iter.item}" )
	end
	
	#Test that the length returned by the tree under various insertion/deletion is always
	#adequate.
	fun test_length() do
		clear
		assert_true( length == 0, "empty tree has a length of {length}" )
		insert( make_element( 0 ) )
		assert_true( length == 1, "one element tree has a length of {length}" )
		remove( 0 )
		assert_true( length == 0, "empty tree after removal has a length of {length}" )
		random_inserts( 0 , 100 )
		assert_true( length == 100, "100 elements tree has a length of {length}" )
		random_removals( 20, 70 )
		assert_true( length == 50, "50 elements tree after 50 removals have length of {length}" )
		random_removals( 0, 20 )
		random_removals( 70, 100 )
		assert_true( length == 0, "empty tree after 50 removals have length of {length}" )
	end
	
	#Test basic insertions and uses the iteration to verify that inserted
	#elements can be accessed in the correct order (ascending/descending).
	fun test_insertions() do
		var expected_result = new Array[ Element ].with_capacity( 100 )
		var reverse_exp_res = new Array[ Element ].with_capacity( 100 )
		for i in [ 0 .. 100 [ do
			expected_result[ i ] = make_element( i )
			reverse_exp_res[ i ] = make_element( 99 - i )
		end
		validate( "empty tree invalid" )
		clear
		validate( "cleared tree invalid" )
		#Forward insertions.
		clear
		forward_inserts( 0, 100 )
		validate( "tree after forward insertions invalid" )
		test_equals( expected_result.iterator, iterator )
		test_equals( reverse_exp_res.iterator, reverse_iterator )
		#Backward insertions.
		clear		
		backward_inserts( 0, 100 )
		validate( "tree after backward insertions invalid" )
		test_equals( expected_result.iterator, iterator )
		test_equals( reverse_exp_res.iterator, reverse_iterator )
		#Mixed insertions.
		clear
		forward_inserts( 0, 50 )
		backward_inserts( 50, 100 )
		validate( "tree after mixed insertions invalid" )
		test_equals( expected_result.iterator, iterator )
		test_equals( reverse_exp_res.iterator, reverse_iterator )
		#Random insertions.
		clear
		random_inserts( 0, 100 )
		validate( "invalid tree after random insertions")
		test_equals( expected_result.iterator, iterator )
		test_equals( reverse_exp_res.iterator, reverse_iterator )	
	end
	
	#---------------------------------------
	#Utility methods
	#---------------------------------------
	
	#Asserts that both iterator returns the same element, as provided by the tree comparator.
	#Prints an error message if both iteration does not return the same set of elements.
	protected fun test_equals( exp_res_iter: Iterator[ Element ], eff_res_iter: Iterator[ Element ] ) do
		var algos = new Algos()
		var exp_res = new List[ Key ]
		while exp_res_iter.is_ok do
			exp_res.push( extract_key( exp_res_iter.item ) )
			exp_res_iter.next
		end
		var eff_res = new List[ Key ]
		while eff_res_iter.is_ok do
			eff_res.push( extract_key( eff_res_iter.item ) )
			eff_res_iter.next
		end
		assert_true( 
			algos.equals( exp_res.iterator, eff_res.iterator, new ComparatorEquals[ Key, Key ]( comparator ) ), 
			"Test equals failure\n" + "Expected result: " + exp_res.join( ", " ) + "\nEffective result: " + eff_res.join( ", " )		
		)
	end

	#Sequentially inserts elements between [ min .. max [
	protected fun forward_inserts( min: Int, max: Int ) do
		for i in [ min .. max [ do
			insert( make_element( i ) )
		end
	end
	
	#Sequentially removes elements between [ min .. max [
	protected fun forward_removals( min: Int, max: Int ) do
		for i in [ min .. max [ do
			remove( i )
		end
	end

	#Sequentially inserts elements between [ min .. max ], but in the reverse order.
	protected fun backward_inserts( min: Int, max: Int ) do
		var i = max - 1
		while min <= i do
			insert( make_element( i ) )
			i -= 1
		end
	end

	#Sequentially removes elements between [ min .. max ], but in the reverse order.
	protected fun backward_removals( min: Int, max: Int ) do
		var i = max - 1
		while min <= i do
			remove( i )
			i -= 1
		end
	end

	#Inserts the given element the number of times provided.
	protected fun same_inserts( value: Int, times: Int ) do 
		for i in [ 1 .. times ] do
			insert( make_element( value ) )
		end
	end

	#Removes the given element the number of times provided.
	protected fun same_removals( value: Int, times: Int ) do 
		for i in [ 1 .. times ] do
			remove( value )
		end
	end

	#Randomly inserts elements from [ min ... max [.
	protected fun random_inserts( min: Int, max: Int ) do
		var count = max - min
		var table = new Array[ Element ].with_capacity( count )
		for i in [ 0 .. count [ do
			table[ i ] = make_element( i + min )
		end
		while not table.is_empty do
			var random_idx = count.rand
			insert( table[ random_idx ] )
			table.remove_at( random_idx )
			count -= 1
		end
	end

	#Randomly removes elements from [ min ... max [.
	protected fun random_removals( min: Int, max: Int ) do
		var count = max - min
		var table = new Array[ Int ].with_capacity( count )
		for i in [ 0 .. count [ do
			table[ i ] = i + min
		end
		while not table.is_empty do
			var random_idx = count.rand
			remove( table[ random_idx ] )
			table.remove_at( random_idx )
			count -= 1
		end
	end
	
	#---------------------------------------
	#Abstract utilities
	#---------------------------------------
	
	#Calls the validator and asserts its validity. If the result is
	#invalid (the rb tree is infringing one of its property), then 
	#the message is used as the assertion failure message. This method
	#must be redefined because this class has no way of knowing what
	#type of tree is used (needed by the validator)
	protected fun validate( msg: String ) is abstract
	#Returns an element base on the provided int (will behave differently
	#if the tree is a variant of the set or a variant of the map).
	protected fun make_element( v: Int ): Element is abstract
	#
	protected fun extract_key( e: Element ): Key is abstract
	
	#---------------------------------------
	#Tree methods
	#Since this class cannot make any assumptions regarding
	#the type and the way trees are handled, it forces leaf
	#test classes to provide those facilities in order
	#to generalize basic tests. Those are really just
	#dispatching methods so no documentation needs to be provided
	#here.
	#---------------------------------------
	
	protected fun highest(): RBTreeBiIterator[ Element ] is abstract 
	protected fun lowest(): RBTreeBiIterator[ Element ] is abstract 
	protected fun use_comparator( c: Comparator[ Key, Key ] ) is abstract
	protected fun comparator(): Comparator[ Key, Key ] is abstract
	protected fun find( e: Key ): RBTreeBiIterator[ Element ] is abstract
	protected fun floor( e: Key ): RBTreeBiIterator[ Element ] is abstract
	protected fun ceiling( e: Key ): RBTreeBiIterator[ Element ] is abstract
	protected fun has( e: Key ): Bool is abstract
	protected fun is_empty(): Bool is abstract
	protected fun length(): Int is abstract
	protected fun clear() is abstract
	protected fun insert( e: Element ) is abstract
	protected fun remove( e: Key ) is abstract
	protected fun remove_at( i: RBTreeIterator[ Element ] ): RBTreeIterator[ Element ] is abstract
	protected fun iterator(): RBTreeBiIterator[ Element ] is abstract
	protected fun reverse_iterator(): RBTreeRIterator[ Element ] is abstract
end

#Extends the testing algorithms to test that the collections
#prevent insertion of duplicates.
class SinglyValuedTests
	super RBTreeBaseTests
	
	redef fun test_retrievals() do
		super
		var algos = new Algos
		clear
		random_inserts( 0, 100 )
		same_inserts( 50, 19 )
		var iter = find( 50 )
		assert_true( 
			comparator.call( extract_key( iter.item ), 50 ) == 0,
			"retrieving 50 on 20 fake duplicates returned an iterator on {iter.item}" 
		)
		iter.next
		assert_true( 
			comparator.call( extract_key( iter.item ), 51 ) == 0,
			"moving on the next element on 20 fakes duplicates returned {iter.item}" 
		)
		iter.previous
		iter.previous
		assert_true( 
			comparator.call( extract_key( iter.item ), 49 ) == 0,
			"moving on the previous element on 20 fakes duplicates returned {iter.item}" 
		)
	end	
	
	redef fun test_removals() do
		super
		clear
		random_inserts( 0, 100 )
		same_inserts( 50, 19 )
		assert_true( has( 50 ), "unable to retrieve element 50 after insertion of 20 duplicates" )
		remove( 50 )
		assert_false( has( 50 ), "still able to retrieve element 50 after one instance has been removed" )
		same_removals( 50, 4 )
		assert_false( has( 50 ), "able to retrieve 50 after further removals even if it was previously unexistant" )
		clear
		assert_true( is_empty, "clear tree is not empty" )		
	end
	
	redef fun test_length() do
		super
		clear
		random_inserts( 0, 100 )
		same_inserts( 50, 20 )
		assert_true( length == 100, "inserting 20 duplicates on a 100 elements tree returns a length of {length}" )
		same_removals( 50, 20 )
		assert_true( length == 99, "removing all duplicates returns a length of {length} (expecting 99)" )
		random_removals( 0, 100 )
		assert_true( length == 0, "empty tree have length of {length}" )
		clear
		assert_true( length == 0, "cleared tree have length of {length}" )		
	end
	
	redef fun test_insertions() do
		super
		#Testing with multiple pair of values.
		var expected_result = new Array[ Element ].with_capacity( 100 )
		var reverse_exp_res = new Array[ Element ].with_capacity( 100 )
		for i in [ 0 .. 100 [ do
			expected_result[ i ] = make_element( i )
			reverse_exp_res[ i ] = make_element( 99 - i )
		end
		clear
		random_inserts( 0, 100 )
		#Notice the second insertion pass.
		random_inserts( 0, 100 )
		validate( "invalid tree after duplicate random insertions")
		test_equals( expected_result.iterator, iterator )
		test_equals( reverse_exp_res.iterator, reverse_iterator )
		#Testing with groups of 10 mixed with some singletons.
		expected_result = new Array[ Element ].with_capacity( 20 )
		for i in [ 0 .. 20 [ do
			expected_result[ i ] = make_element( i )
		end
		reverse_exp_res = expected_result.reversed
		
		clear
		for i in [ 0 .. 10 [ do
			random_inserts( 0, 15 )
		end
		random_inserts( 15, 20 )
		validate( "invalid tree mixed duplicate random insertions")
		test_equals( expected_result.iterator, iterator )
		test_equals( reverse_exp_res.iterator, reverse_iterator )
	end
	
	redef fun test_other_comparator() do
		super
		clear
		random_inserts( 0, 100 )
		same_inserts( 50, 19 )
		assert_true( length == 100, "inserting 19 fake duplicates on a 100 element tree returns a size of {length}" )
		assert_true( has( 50 ), "cannot retrieve element 50" )
	end
	
end

#This class extends the test cases make sure 
#the collections support duplicate values.
class MultiValuedTests
	super RBTreeBaseTests
	
	redef fun test_retrievals() do
		super
		
		var algos = new Algos
		
		clear
		random_inserts( 0, 100 )
		same_inserts( 50, 19 )

		assert_true( count( 50 ) == 20, "20 duplicates of 50 returns a count of {count(50)}" )		
		var iter = find( 50 )
		assert_true( 
			comparator.call( extract_key( iter.item ), 50 ) == 0,
			"retrieving 50 on 20 duplicates returned an iterator on {iter.item}" )
		iter = floor( 50 )
		assert_true( comparator.call( extract_key( iter.item ), 50 ) == 0, "retrieving floor of 50 on 20 duplicates returned an iterator on {iter.item}" )
		iter.next
		assert_true( comparator.call( extract_key( iter.item ), 50 ) == 0, "next on floor of 20 duplicates of 50 is {iter.item}" )
		iter.previous
		iter.previous
		assert_true( comparator.call( extract_key( iter.item ), 49 ) == 0, "previous on floor of 20 duplicates of 50 is {iter.item}" )
		iter = ceiling( 50 )
		assert_true( 
			comparator.call( extract_key( iter.item ), 50 ) == 0,
			"retrieving ceiling of 50 on 20 duplicates returned an iterator on {iter.item}" )
		iter.next
		assert_true( comparator.call( extract_key( iter.item ), 51 ) == 0, "next on ceiling of 20 duplicates of 50 is {iter.item}" )
		iter.previous
		iter.previous
		assert_true( comparator.call( extract_key( iter.item ), 50 ) == 0, "previous on ceiling of 20 duplicates of 50 is {iter.item}" )
		
		#This here is a special case known to have broken the tree at least once.
		clear
		same_inserts( 0, 2 )
		same_inserts( 100, 1 )
		same_inserts( 50, 5 )
		assert_true( count( 50 ) == 5, "5 duplicates of 50 returns a count of {count(50)}" )	
		iter = find( 50 )
		assert_true( 
			comparator.call( extract_key( iter.item ), 50 ) == 0,
			"retrieving 50 on 5 duplicates returned an iterator on {iter.item}" )
		iter = floor( 50 )
		assert_true( comparator.call( extract_key( iter.item ), 50 ) == 0, "retrieving floor of 50 on 5 duplicates returned an iterator on {iter.item}" )
		iter.next
		assert_true( comparator.call( extract_key( iter.item ), 50 ) == 0, "next on floor of 5 duplicates of 50 is {iter.item}" )
		iter.previous
		iter.previous
		assert_true( comparator.call( extract_key( iter.item ), 0 ) == 0, "previous on floor of 5 duplicates of 50 is {iter.item}" )
		iter = ceiling( 50 )
		assert_true( 
			comparator.call( extract_key( iter.item ), 50 ) == 0,
			"retrieving ceiling of 50 on 5 duplicates returned an iterator on {iter.item}" )
		iter.next
		assert_true( comparator.call( extract_key( iter.item ), 100 ) == 0, "next on ceiling of 5 duplicates of 50 is {iter.item}" )
		iter.previous
		iter.previous
		assert_true( comparator.call( extract_key( iter.item ), 50 ) == 0, "previous on ceiling of 5 duplicates of 50 is {iter.item}" )		
	end	
	
	redef fun test_removals() do
		super
		clear
		random_inserts( 0, 100 )
		same_inserts( 50, 19 )
		assert_true( count( 50 ) == 20, "inserting 20 duplicates returns a count of {count( 50 )}" )
		remove( 50 )
		assert_true( count( 50 ) == 19, "removing 1 duplicate out of 20 returns a count of {count( 50 )}" )
		same_removals( 50, 4 )
		assert_true( count( 50 ) == 15, "removing 5 duplicate out of 20 returns a count of {count( 50 )}" )
		forward_removals( 0, 51 )
		assert_true( count( 50 ) == 14, "removing 6 duplicate out of 20 returns a count of {count( 50 )}" )
		remove( 51 )
		assert_true( count( 50 ) == 14, "removing another element returns a count of {count( 50 )}" )
		random_removals( 50, 100 )
		assert_true( count( 50 ) == 13, "removing 7 duplicate out of 20 returns a count of {count( 50 )}" )
		same_removals( 50, 13 )
		assert_true( count( 50 ) == 0, "removing all duplicate out of 20 returns a count of {count( 50 )}" )
		same_removals( 50, 20 )
		assert_true( count( 50 ) == 0, "removing unexisting duplicates returns a count of {count( 50 )}" )	
		
		#Testing the remove_at feature when removing a group
		clear
		random_inserts( 0, 100 )
		same_inserts( 50, 19 )
		var f = floor( 50 )
		assert_true( comparator.call( extract_key( f.item ), 50 ) == 0, "retrieving floor of 50 returned an iterator on {f.item}" )
		while comparator.call( extract_key( f.item ), 50 ) == 0 do
			remove_at( f )
		end
		assert_true( count( 50 ) == 0, "did not remove all occurrences, missing {count(50)}" )
		assert_true( length == 99, "removed more than just the duplicates, new length is {length}" )
		assert_true( comparator.call( extract_key( f.item ), 51 ) == 0, "iter on {f.item} after removals" )
		#Redoing the same thing but with the reverse iterator.
		same_inserts( 50, 20 )
		var c = ceiling( 50 ).reverse
		assert_true( comparator.call( extract_key( c.item ), 50 ) == 0, "retrieving floor of 50 returned an iterator on {c.item}" )
		while comparator.call( extract_key( c.item ), 50 ) == 0 do
			remove_at( c )
		end
		assert_true( count( 50 ) == 0, "did not remove all occurrences, missing {count(50)}" )
		assert_true( length == 99, "removed more than just the duplicates, new length is {length}" )
		assert_true( comparator.call( extract_key( c.item ), 49 ) == 0, "iter on {c.item} after reverse removals" )
	end
	
	redef fun test_length() do
		super
		clear
		random_inserts( 0, 100 )
		same_inserts( 50, 20 )
		assert_true( length == 120, "120 element tree has a length of {length}" )
		same_removals( 50, 20 )
		random_removals( 0, 100 )
		assert_true( length == 0, "empty tree after 120 removals have length of {length}" )
	end
	
	redef fun test_insertions() do
		super
		#Testing with multiple pair of values.
		var expected_result = new Array[ Element ].with_capacity( 200 )
		var reverse_exp_res = new Array[ Element ].with_capacity( 200 )
		for i in [ 0 .. 200 [ do
			expected_result[ i ] = make_element( i / 2 )
			reverse_exp_res[ i ] = make_element( 99 - ( i / 2 ) )
		end
		clear
		random_inserts( 0, 100 )
		random_inserts( 0, 100 )
		validate( "invalid tree after duplicate random insertions")
		test_equals( expected_result.iterator, iterator )
		test_equals( reverse_exp_res.iterator, reverse_iterator )
		#Testing with groups of 10 mixed with some singletons.
		expected_result = new Array[ Element ].with_capacity( 200 )
		reverse_exp_res = new Array[ Element ].filled_with( 0, 200 )
		for i in [ 0 .. 200 [ do
			if i < 180 then
				expected_result[ i ] = make_element( i / 10 )
				reverse_exp_res[ 199 - i ] = make_element( i / 10 )
			else
				expected_result[ i ] = make_element( i )
				reverse_exp_res[ 199 - i ] = make_element( i )
			end
		end
		clear
		for i in [ 0 .. 10 [ do
			random_inserts( 0, 18 )
		end
		random_inserts( 180, 200 )
		validate( "invalid tree mixed duplicate random insertions")
		test_equals( expected_result.iterator, iterator )
		test_equals( reverse_exp_res.iterator, reverse_iterator )
	end
	
	redef fun test_other_comparator() do
		super
		clear
		random_inserts( 0, 100 )
		same_inserts( 50, 19 )
		assert_true( length == 119, "inserting 19 duplicates on a 100 element tree returns a size of {length}" )
		assert_true( count( 50 ) == 20, "count of 20 duplicates returns {count(50)}" )
	end
	
	protected fun count( e: Key ): Int is abstract
end

#Test class for tree sets.
#This class redefines every property to allow the general
#algorithms to work properly. It is nothing but the bridge
#between the algorithms and the tree.
class TreeSetTests 
	super SinglyValuedTests
	
	redef type Element: Int
	redef type Key: Int
	private var tree: TreeSet[ Element ]
	private var validator: RBTreeValidator

	init () do
		self.tree = new TreeSet[ Element ]
		self.validator = new RBTreeValidator.set( self.tree )
	end
	redef fun test_all() do
		print "\nTesting set"
		print "*****************************"
		super
		print "*****************************"
	end
	
	redef fun highest() do
		return self.tree.highest
	end
	redef fun lowest() do
		return self.tree.lowest
	end
	redef fun use_comparator( c: Comparator[ Key, Key ] ) do
		self.tree = new TreeSet[ Element ].with_comparator( c )
	end
	redef fun find( e ) do
		return self.tree.find( e )
	end
	redef fun floor( e ) do
		return self.tree.floor( e )
	end
	redef fun ceiling( e ) do
		return self.tree.ceiling( e )
	end
	redef fun has( e ) do
		return self.tree.has( e )
	end
	redef fun comparator() do
		return self.tree.comparator
	end
	redef fun is_empty(): Bool do
		return self.tree.is_empty
	end
	redef fun length() do
		return self.tree.length
	end
	redef fun clear() do 
		self.tree.clear
	end
	redef fun insert( e ) do
		self.tree.insert( e )
	end
	redef fun remove( e ) do
		self.tree.remove_at( self.tree.find( e ) )
	end
	redef fun make_element( v ) do
		return v
	end
	redef fun extract_key( v ) do
		return v
	end
	redef fun validate( msg ) do
		self.validator.validate.assert_valid( msg )
	end
	redef fun iterator() do
		return self.tree.iterator
	end
	redef fun reverse_iterator() do
		return self.tree.reverse_iterator
	end
	redef fun remove_at( i ) do
		return self.tree.remove_at( i )
	end
end

#Test class for tree multisets.
#This class redefines every property to allow the general
#algorithms to work properly. It is nothing but the bridge
#between the algorithms and the tree.
class TreeMultisetTests 
	super MultiValuedTests
	
	redef type Element: Int
	redef type Key: Int
	private var tree: TreeMultiset[ Element ]
	private var validator: RBTreeValidator
	
	init () do
		self.tree = new TreeMultiset[ Element ]
		self.validator = new RBTreeValidator.multiset( self.tree )
	end
	redef fun test_all() do
		print "\nTesting multiset"
		print "*****************************"
		super
		print "*****************************"
	end
	
	redef fun highest() do
		return self.tree.highest
	end
	redef fun lowest() do
		return self.tree.lowest
	end
	redef fun use_comparator( c: Comparator[ Key, Key ] ) do
		self.tree = new TreeMultiset[ Element ].with_comparator( c )
	end
	redef fun find( e ) do
		return self.tree.find( e )
	end
	redef fun floor( e ) do
		return self.tree.floor( e )
	end
	redef fun ceiling( e ) do
		return self.tree.ceiling( e )
	end
	redef fun has( e ) do
		return self.tree.has( e )
	end
	redef fun comparator() do
		return self.tree.comparator
	end
	redef fun is_empty(): Bool do
		return self.tree.is_empty
	end
	redef fun length() do
		return self.tree.length
	end
	redef fun clear() do 
		self.tree.clear
	end
	redef fun insert( e ) do
		self.tree.insert( e )
	end
	redef fun remove( e ) do
		self.tree.remove_at( self.tree.find( e ) )
	end
	redef fun count( e ) do
		return self.tree.count( e )
	end
	redef fun make_element( v ) do
		return v
	end
	redef fun extract_key( v ) do
		return v
	end
	redef fun validate( msg ) do
		self.validator.validate.assert_valid( msg )
	end
	redef fun iterator() do
		return self.tree.iterator
	end
	redef fun reverse_iterator() do
		return self.tree.reverse_iterator
	end
	redef fun remove_at( i ) do
		return self.tree.remove_at( i )
	end
end

#Test class for tree maps.
#This class redefines every property to allow the general
#algorithms to work properly. It is nothing but the bridge
#between the algorithms and the tree.
class TreeMapTests 
	super SinglyValuedTests
	
	redef type Element: MapEntry[ Int, String ]
	redef type Key: Int
	private var tree: TreeMap[ Int, String ]
	private var validator: RBTreeValidator

	init () do
		self.tree = new TreeMap[ Int, String ]
		self.validator = new RBTreeValidator.map( self.tree )
	end
	
	redef fun test_all() do
		print "\nTesting map"
		print "*****************************"
		super
		print "*****************************"
	end	
	
	redef fun highest() do
		return self.tree.highest
	end
	redef fun lowest() do
		return self.tree.lowest
	end
	redef fun use_comparator( c: Comparator[ Key, Key ] ) do
		self.tree = new TreeMap[ Int, String ].with_comparator( c )
	end
	redef fun find( e ) do
		return self.tree.find( e )
	end
	redef fun floor( e ) do
		return self.tree.floor( e )
	end
	redef fun ceiling( e ) do
		return self.tree.ceiling( e )
	end
	redef fun has( e ) do
		return self.tree.has( e )
	end
	redef fun comparator() do
		return self.tree.comparator
	end
	redef fun is_empty(): Bool do
		return self.tree.is_empty
	end
	redef fun length() do
		return self.tree.length
	end
	redef fun clear() do 
		self.tree.clear
	end
	redef fun insert( e ) do
		self.tree.insert( e )
	end
	redef fun remove( e ) do
		self.tree.remove_at( self.tree.find( e ) )
	end
	redef fun make_element( v ) do
		return new MapEntry[ Int, String ]( v, v.to_s )
	end
	redef fun extract_key( v ) do
		return v.key
	end
	redef fun validate( msg ) do
		self.validator.validate.assert_valid( msg )
	end
	redef fun iterator() do
		return self.tree.iterator
	end
	redef fun reverse_iterator() do
		return self.tree.reverse_iterator
	end
	redef fun remove_at( i ) do
		return self.tree.remove_at( i )
	end
end

#Test class for tree multimaps.
#This class redefines every property to allow the general
#algorithms to work properly. It is nothing but the bridge
#between the algorithms and the tree.
class TreeMultimapTests 
	super MultiValuedTests
	
	redef type Element: MapEntry[ Int, String ]
	redef type Key: Int
	private var tree: TreeMultimap[ Int, String ]
	private var validator: RBTreeValidator
	
	init () do
		self.tree = new TreeMultimap[ Int, String ]
		self.validator = new RBTreeValidator.multimap( self.tree )
	end
	redef fun test_all() do
		print "\nTesting multimap"
		print "*****************************"
		super
		print "*****************************"
	end
	
	redef fun highest() do
		return self.tree.highest
	end
	redef fun lowest() do
		return self.tree.lowest
	end
	redef fun use_comparator( c: Comparator[ Key, Key ] ) do
		self.tree = new TreeMultimap[ Int, String ].with_comparator( c )
	end	
	redef fun find( e ) do
		return self.tree.find( e )
	end
	redef fun floor( e ) do
		return self.tree.floor( e )
	end
	redef fun ceiling( e ) do
		return self.tree.ceiling( e )
	end
	redef fun has( e ) do
		return self.tree.has( e )
	end
	redef fun comparator() do
		return self.tree.comparator
	end
	redef fun is_empty(): Bool do
		return self.tree.is_empty
	end
	redef fun length() do
		return self.tree.length
	end
	redef fun clear() do 
		self.tree.clear
	end
	redef fun insert( e ) do
		self.tree.insert( e )
	end
	redef fun remove( e ) do
		self.tree.remove_at( self.tree.find( e ) )
	end
	redef fun count( e ) do
		return self.tree.count( e )
	end
	redef fun make_element( v ) do
		return new MapEntry[ Int, String ]( v, v.to_s )
	end
	redef fun extract_key( v ) do
		return v.key
	end
	redef fun validate( msg ) do
		self.validator.validate.assert_valid( msg )
	end
	redef fun iterator() do
		return self.tree.iterator
	end
	redef fun reverse_iterator() do
		return self.tree.reverse_iterator
	end
	redef fun remove_at( i ) do
		return self.tree.remove_at( i )
	end
end

#Launches all test cases.
var mset_tests = new TreeMultisetTests()
mset_tests.test_all
var set_tests = new TreeSetTests()
set_tests.test_all
var map_tests = new TreeMapTests()
map_tests.test_all
var mmap_tests = new TreeMultimapTests()
mmap_tests.test_all
