interface Position[ T ]
	type Compared: Position[ T ]

	fun is_ok(): Bool is abstract
	fun item: T is abstract
	fun equals( c: Compared ): Bool is abstract
end

interface Iter[ T ]
	super Position[ T ]
	fun next() is abstract
end

interface ReversibleIter[ T ] super Iter[ T ]
	fun reverse(): ReversibleIter[ T ] is abstract
end

interface BidirectionalIter[ T ] super ReversibleIter[ T ]
	fun previous() is abstract
end

interface RandomAccessIter[ T ] super BidirectionalIter[ T ]
	type PosType: Position[ T ]
	fun move_to( p: PosType ) is abstract
end



