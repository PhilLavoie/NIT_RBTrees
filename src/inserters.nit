interface Inserter[ T ]
	fun insert( e: T ) is abstract
end

interface SortedInsertable[ T ]
	fun insert( e: T ) is abstract
end

interface BackInsertable[ T ]
	fun push( e: T ) is abstract
end

interface FrontInsertable[ T ]
	fun unshift( e: T ) is abstract
end

class SortedInserter[ T ]
	super Inserter[ T ]

	private var s_insertable: SortedInsertable[ T ]
	init ( i: SortedInsertable[ T ] ) do
		self.s_insertable = i
	end
	redef fun insert( e ) do
		self.s_insertable.insert( e )
	end
end

class BackInserter[ T ]
	super Inserter[ T ]

	private var b_insertable: BackInsertable[ T ]
	init ( i: BackInsertable[ T ] ) do
		self.b_insertable = i
	end
	redef fun insert( e ) do
		self.b_insertable.push( e )
	end
end

class FrontInserter[ T ]
	super Inserter[ T ]

	private var f_insertable: FrontInsertable[ T ]
	init ( i: FrontInsertable[ T ] ) do
		self.f_insertable = i
	end
	redef fun insert( e ) do
		self.f_insertable.unshift( e )
	end
end
