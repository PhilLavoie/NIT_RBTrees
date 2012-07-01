import functions
import inserters
import iterators

class Algos
	fun equals( lhs_iter: Iterator[ nullable Object ], rhs_iter: Iterator[ nullable Object ] ): Bool do
		while lhs_iter.is_ok and rhs_iter.is_ok do
			if lhs_iter.item != rhs_iter.item then return false
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
	
	fun size( iter: Iterator[ nullable Object ] ): Int do
		var res = 0
		while iter.is_ok do
			res += 1
			iter.next
		end
		return res
	end
	
	fun count( iter: Iterator[ nullable Object ], e: nullable Object ): Int do
		var res = 0
		while iter.is_ok do
			find( iter, e )
			if iter.is_ok then res += 1 else break
			iter.next
		end
		return res
	end
	
	fun find( iter: Iterator[ nullable Object ], e: nullable Object ): Iterator[ nullable Object ] do
		while iter.is_ok do
			if iter.item is e or iter.item == e then break
			iter.next
		end
		return iter
	end
	
	fun copy( iter: Iterator[ nullable Object ], inserter: Inserter[ nullable Object ] ) do
		while iter.is_ok do
			inserter.insert( iter.item )
			iter.next
		end
	end
end
