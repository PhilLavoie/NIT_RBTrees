#interface Position[ T ]
#	type Compared: Position[ T ]

#	fun is_ok(): Bool is abstract
#	fun item: T is abstract
#	fun equals( c: Compared ): Bool is abstract
#end

redef interface Iterator[ T ]
#	super Position[ T ]
#	fun next() is abstract
	fun clone(): Iterator[ T ] is abstract
end

interface ReversibleIterator[ T ] super Iterator[ T ]
	fun reverse(): ReversibleIterator[ T ] is abstract
end

interface BidirectionalIterator[ T ] super ReversibleIterator[ T ]
	fun previous() is abstract
end

interface RandomAccessIterator[ T ] super BidirectionalIterator[ T ]
#	type PosType: Position[ T ]
#	fun move_to( p: PosType ) is abstract
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
 

