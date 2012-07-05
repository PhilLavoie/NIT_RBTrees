interface UnaryFunctor[ T, R ]
	fun call( e: T ): R is abstract
end

interface UnaryProctor[ T ]
	fun call( e: T ) is abstract
end

interface UnaryPredicate[ T ]
	super UnaryFunctor[ T, Bool ]
end


interface BinaryFunctor[ T, U, R ]
	fun call( lhs: T, rhs: U ): R is abstract
end

interface BinaryProctor[ T, U ]
	fun call( lhs: T, rhs: U ) is abstract
end

interface BinaryPredicate[ T, U ]
	super BinaryFunctor[ T, U, Bool ]
end

interface Comparator[ T, U ]
	super BinaryFunctor[ T, U, Int ]
end

interface Equals[ T, U ]
	super BinaryFunctor[ T, U, Bool ]
end

class DefaultEquals[ T, U ]
	super Equals[ T, U ]
	redef fun call( lhs, rhs ) do
		return lhs is rhs or lhs == rhs
	end
end

class ComparatorEquals[ T, U ]
	super Equals[ T, U ]
	var comparator: Comparator[ T, U ]
	init ( c: Comparator[ T, U ] ) do
		self.comparator = c
	end
	redef fun call( lhs, rhs ) do
		return self.comparator.call( lhs, rhs ) == 0
	end
end

class EquivalenceComparator[ T, U ]
	super Comparator[ T, U ]
	redef fun call( lhs, rhs ) do
		var l = new OperatorLess[ T, U ]
		if l.call( lhs, rhs ) then
			return -1
		else if l.call( rhs, lhs ) then
			return 1
		end
		return 0
	end
end

class DefaultComparator[ T, U ]
	super Comparator[ T, U ]
	redef fun call( lhs, rhs ) do
		var l = new OperatorLess[ T, U ]
		var e = new DefaultEquals[ T, U ]
		if l.call( lhs, rhs ) then
			return -1
		else if e.call( lhs, rhs ) then
			return 0
		end
		return 1
	end
end

class OperatorLess[ T, U ]
	super BinaryPredicate[ T, U ]
	redef fun call( lhs, rhs ) do
		return lhs.as( Comparable ) < rhs.as( Comparable )
	end
end

