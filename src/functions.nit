

#Unary function object interface.
interface UnaryFunctor[ T, R ]
	fun call( e: T ): R is abstract
end

#Unary procedure object interface.
interface UnaryProctor[ T ]
	fun call( e: T ) is abstract
end

#Unary predicate object interface.
interface UnaryPredicate[ T ]
	super UnaryFunctor[ T, Bool ]
end

#Binary function object interface.
interface BinaryFunctor[ T, U, R ]
	fun call( lhs: T, rhs: U ): R is abstract
end

#Binary procedure object interface.
interface BinaryProctor[ T, U ]
	fun call( lhs: T, rhs: U ) is abstract
end

#Binary predicate object interface.
interface BinaryPredicate[ T, U ]
	super BinaryFunctor[ T, U, Bool ]
end

#Comparator object interface.
#A comparator must return a value < 0, == 0 or
#> 0 when the left hand side element is lower than,
#equals or greater than the right hand side element
#respectively.
interface Comparator[ T, U ]
	super BinaryFunctor[ T, U, Int ]
end

#Equality object interface.
#Returns true only if both elements are equals.
interface Equals[ T, U ]
	super BinaryFunctor[ T, U, Bool ]
end

#Default equality object.
#The comparison is based first on the references
#and then on the operator ==.
class DefaultEquals[ T, U ]
	super Equals[ T, U ]
	redef fun call( lhs, rhs ) do
		return lhs is rhs or lhs == rhs
	end
end

#A binder object made to transform a comparator
#into an equality object.
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

#Equivalence comparator.
#This one uses only the operator < to determine its 
#return value. Returns 0 only when there is an equivalence
#relationship (lhs !< rhs and rhs !< lhs).
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

#Default comparator.
#Uses both the operator < and ==.
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

#A predicate object wrapping the behavior
#of the operator <.
class OperatorLess[ T, U ]
	super BinaryPredicate[ T, U ]
	redef fun call( lhs, rhs ) do
		return lhs.as( Comparable ) < rhs.as( Comparable )
	end
end

