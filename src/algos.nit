import functions
import inserters
import iterators

#This class offers common algorithms based on iteration.
#As of right now, it is only a stub and its main purpose was more
#a proof of concept than anything else.
class Algos
	#Returns true only if, according to the equality object, all
	#elements returned by the iterators are equals. In other words,
	#it tests for content equality. If both iterators don't have the
	#same number of steps, then false is returned. If both iterators
	#return nothing (empty collections for example), then true
	#is returned.
	fun equals( 
		lhs_iter: Iterator[ nullable Object ],
		rhs_iter: Iterator[ nullable Object ], 
		equals: Equals[ nullable Object, nullable Object ] 
		): Bool do
		while lhs_iter.is_ok and rhs_iter.is_ok do
			if not equals.call( lhs_iter.item , rhs_iter.item ) then return false
			lhs_iter.next
			rhs_iter.next
		end
		if lhs_iter.is_ok != rhs_iter.is_ok then return false
		return true
	end
	
	#Loop generalization.
	#It passes the element extracted from the iterator to the unary procedure and that,
	#for all elements.
	fun for_each( iter: Iterator[ nullable Object], f: UnaryProctor[ nullable Object ] ) do
		while iter.is_ok do
			f.call( iter.item )
			iter.next
		end
	end
	
	#Returns the number of steps made by the iterator before falling out of range.
	fun length( iter: Iterator[ nullable Object ] ): Int do
		var size = 0
		while iter.is_ok do
			size += 1
			iter.next
		end
		return size
	end
	
	#Passes on the element returned by the iterator to the inserter for every element
	#encountered.
	fun copy( iter: Iterator[ nullable Object ], inserter: Inserter[ nullable Object ] ) do
		while iter.is_ok do
			inserter.insert( iter.item )
			iter.next
		end
	end
end
