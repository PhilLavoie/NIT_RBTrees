import finders

interface Removable[ T ]
	type PosType: Position[ T ]
	fun remove_at( pos: PosType ) is abstract
end

class Remover[ T ]
	private var removee: Removable[ T ]
	private var finder: Finder[ T ]	
	
	init ( r: Removable[ T ], f: Finder[ T ] ) do
		self.removee = r
		self.finder = f
	end
	
	fun remove( e: T ) do
		var pos = self.finder.find( e )
		if pos.is_ok then 
			self.removee.remove_at( pos )
		end
	end
	
	fun remove_all( e: T ) do
		var pos = self.finder.find( e )
		while pos.is_ok do
			self.removee.remove_at( pos )
		end
	end
end


