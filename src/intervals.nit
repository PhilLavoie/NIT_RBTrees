import iterators
import functions
import inserters

abstract class Interval[ T ]
	type PosType: Position[ T ]
	type IterType: Iter[ T ]

	protected var start: PosType
	protected var stop: PosType
	
	init empty() do
		self.start = invalid_pos
		self.stop = invalid_pos
	end
	
#Mainly for convenience, but might be polluting.
#	init from( start: PosType ) do
#		self.start = start
#		self.stop = invalid_pos
#	end
	
	init between( start: PosType, stop: PosType ) do
		self.start = start
		self.stop = stop
	end
	
	fun iterator_on( pos: PosType ): IterType is abstract
	fun invalid_pos(): PosType is abstract
	
	fun size(): Int do
		var counter = 0
		var iter = iterator_on( self.start )
		while iter.is_ok and not iter == self.stop do
			counter += 1
			iter.next
		end
		return counter		
	end
	
	fun count( e: T, c: Equals[ T, T ] ): Int do
		var count = 0
		var iter = iterator_on( self.start )
		while iter.is_ok do
			if c.call( iter.item, e ) then
				count += 1
			end
			iter.next
		end
		return count
	end
	
	fun find( e: T, c: Equals[ T, T ] ): PosType do		
		var iter = iterator_on( self.start )
		while iter.is_ok do
			if c.call( iter.item, e ) then break
			iter.next
		end
		return iter
	end
	
	fun copy( inserter: Inserter[ T ] ) do
		var iter = iterator_on( self.start )
		while iter.is_ok do
			inserter.insert( iter.item )
			iter.next
		end
	end
end

abstract class SortedInterval[ T ] 
	super Interval[ T ]
	
	#Light optimization where the iteration does not go until the
	#end, rather, if the element has been previously found and the
	#current element is different, it is assumed that the rest
	#will be as well (sorted assumption).
	redef fun count( e, c ) do
		var count = 0
		var found = false
		var iter = iterator_on( self.start )
		while iter.is_ok do
			if c.call( iter.item, e ) then
				if not found then found = true
				count += 1
			else if found then
				break
			end
			iter.next
		end
		return count
	end
end

abstract class ReversibleInterval[ T ]
	super Interval[ T ]
	fun reverse(): ReversibleInterval[ T ]
end
