#Redefinition of the iterator interface.
#Provides an additional method, clone (useful when used
#in conjunction with the algorithms, since they move the
#iterators).
redef interface Iterator[ T ]
	fun clone(): Iterator[ T ] is abstract
end

#Interface iterators that can provide a reversed view.
interface ReversibleIterator[ T ] super Iterator[ T ]
	fun reverse(): ReversibleIterator[ T ] is abstract
end

#Interface of bidirectional iterators, that provide the 
#possibility moving backwards.
interface BidirectionalIterator[ T ] super ReversibleIterator[ T ]
	fun previous() is abstract
end

#Special kind of operator used to bound an iteration to an iterator
#(instead of the end of the collection).
#It is to be used like this:
# var iter = new BoundedIterator[ ... ].inclusive( start, stop )
#The iterator is guaranteed to stop the iteration at the given
#location, provided that the iterators redefine the operator 
#== accordingly (should return true for two iterators on the same 
#position and not only for the same reference).
class BoundedIterator[ T ]
	super Iterator[ T ]
	
	private var start: Iterator[ T ]
	private var stop: Iterator[ T ]
	
	#Constructs an iterator that will stop AFTER the stop iterator.
	#Same as calling exclusive with stop.next.
	init inclusive( start: Iterator[ T ], stop: Iterator[ T ] ) do
		self.start = start
		stop.next
		self.stop = stop
	end
	#Constructs an iterator that stops ON the stop iterator.
	init exclusive( start: Iterator[ T ], stop: Iterator[ T ] ) do
		self.start = start
		self.stop = stop
	end
	
	#Returns true if the iterator is ok and different from its stop
	#location.
	redef fun is_ok() do
		return self.start.is_ok and not ( self.start == self.stop )
	end
	
	redef fun item() do
		return self.start.item
	end
	
	redef fun next() do
		self.start.next
	end
	
	redef fun clone() do
		return new BoundedIterator[ T ].exclusive( self.start, self.stop )
	end	
end


