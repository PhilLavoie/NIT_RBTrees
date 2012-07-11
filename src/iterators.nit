redef interface Iterator[ T ]
	fun clone(): Iterator[ T ] is abstract
end

interface ReversibleIterator[ T ] super Iterator[ T ]
	fun reverse(): ReversibleIterator[ T ] is abstract
end

interface BidirectionalIterator[ T ] super ReversibleIterator[ T ]
	fun previous() is abstract
end

interface RandomAccessIterator[ T ] super BidirectionalIterator[ T ]
#TODO only a stub, still have to define what it might look like.
end

#Iterators passed on must be able to compare with each other, specifically
#this has to be supported: start == stop.
class BoundedIterator[ T ]
	super Iterator[ T ]
	
	private var start: Iterator[ T ]
	private var stop: Iterator[ T ]
	
	init inclusive( start: Iterator[ T ], stop: Iterator[ T ] ) do
		self.start = start
		stop.next
		self.stop = stop
	end
	
	init exclusive( start: Iterator[ T ], stop: Iterator[ T ] ) do
		self.start = start
		self.stop = stop
	end
	
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

#Class for compatibility with the standard iterators. Do no call
#equals on those.
#class STDIter[ T ] 
#	super Iter[ T ]
#	var iter: Iterator[ T ]
#	init ( i: Iterator[ T ] ) do
#		self.iter = i
#	end
#	redef fun is_ok() do
#		return self.iter.is_ok
#	end
#	redef fun next() do
#		self.iter.next
#	end
#	redef fun item() do
#		return self.iter.item
#	end
#end
 

