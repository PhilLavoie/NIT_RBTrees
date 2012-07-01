#Just an base class designed to be the mother of all tests classes.
#A test class must offer a testAll function. In addition, some assert
#facilities were added to make coding tests easier.
abstract class Tests

	#Launches all tests.
	fun test_all() is abstract

	#Asserts that the given expression is true, aborts the program
	#and prints the message otherwise.
	protected fun assert_true( bool: Bool, message: String ) do
		assert bool else
			print message
		end
	end
	
	#Same as above, but the expression has to be false.
	protected fun assert_false( bool: Bool, message: String ) do
		assert not bool else
			print "{ message }"
		end
	end

end
