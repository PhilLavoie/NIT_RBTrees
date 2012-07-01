#This class represents the result of an operation. It holds
#the state identifying the correctness of the operation's execution.
#it is to be used as a returned value of a procedure that can
#misbehave. If it has been processed correctly, then the validity
#held by this object shall be true. A false state is always accompanied
#by a message, allowing the user to understand why the operation misbehave.
class Result
	#The error message. Only to be used when the validity state is false.
	var message: String protected writable = ""
	#Validity state of the operation. When this is false, the message should always
	#hold something useful.
	var is_valid: Bool protected writable

	#Creates a valid result.
	init valid() do
		self.is_valid = true
	end

	#Creates an invalid results. The message should always be informational regarding the misbehaving
	#of the operation.
	init invalid( message: String ) do
		self.is_valid = false
		self.message = message
	end
	
	#Useful function added to prevent the user from constantly writing: 
	#assert result.is_valid else
	#	print "{message_prefix}: {result.message}"
	#end.
	#This function does just that. When the message prefix is empty, the method avoids writing
	#any prefix
	fun assert_valid( message_prefix: String ) do
		assert self.is_valid else
			if not message_prefix.is_empty and not self.message.is_empty then
				print "{ message_prefix }: {self.message }"
			else if not self.message.is_empty then
				print "{ self.message }"
			else if not message_prefix.is_empty then
				print "{ message_prefix }"
			end
		end
	end
	
	#Sometimes, an invalid result is what we expect (especially when writing test cases).
	#This method is for thoses scenarios, it asserts that this object is invalid, and prints
	#the message otherwise.
	fun assert_invalid( message: String ) do
		assert not self.is_valid else
			if not message.is_empty then
				print "{message}"
			end
		end
	end
end

#This class is much like its base class, Result, in that it is used
#as a return value for operations. This extension allows for inserting
#a result whenever the operation succeeded. Note that if the result
#is invalid, then the user should not even try to consult the value
class ValuedResult[ Type ]
	super Result

	#Value held by this object. Should only be consulted when the operation
	#has marked this result as valid.
	var value: Type

	#Creates a valid result.
	init valid( value: Type ) do
		self.is_valid = true
		self.value = value
	end

	#Creates an invalid result holding a message.
	init invalid( message: String ) do
		self.is_valid = false
		self.message = message
	end
	
	#Useful function for retrieving the value only if it's valid.
	#This function is used to replace this code:
	#assert valued_result.is_valid else
	#	print "{message_prefix}: {valued_result.message}"
	#end
	#value = valued_result.value
	#Now the user only hase to do this:
	#value = some_function().assertValidAndRetrieve()
	fun assert_valid_and_retrieve( message_prefix: String ): Type do
		self.assert_valid( message_prefix )
		
		return self.value
	end

end
