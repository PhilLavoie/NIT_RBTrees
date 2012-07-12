import functions
import inserters
import iterators

class Algos
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
	
	fun for_each( iter: Iterator[ nullable Object], f: UnaryProctor[ nullable Object ] ) do
		while iter.is_ok do
			f.call( iter.item )
			iter.next
		end
	end
	
#	fun count( iter: Iterator[ nullable Object ], e: nullable Object, equals: Equals[ nullable Object, nullable Object ] ): Int do
#		var res = 0
#		while iter.is_ok do
#			if equals.call( iter.item, e ) then res += 1
#			iter.next
#		end
#		return res
#	end
	
	fun length( iter: Iterator[ nullable Object ] ): Int do
		var size = 0
		while iter.is_ok do
			size += 1
			iter.next
		end
		return size
	end
	
	fun copy( iter: Iterator[ nullable Object ], inserter: Inserter[ nullable Object ] ) do
		while iter.is_ok do
			inserter.insert( iter.item )
			iter.next
		end
	end
end
