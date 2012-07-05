import iterators
import algos

interface Findable[ T ]
	find( e: T ): Position[ T ] is abstract
end

interface Finder[ T ]
	find( e: T ): Position[ T ] is abstract
end

class SortedFinder[ T ]
	super Finder[ T ]
	
	private var findable: Findable[ T ]
	init ( f: Findable[ T ] ) do
		self.findable = f
	end
	redef fun find( e ) do
		return self.findable.find( e )
	end
end

#class AlgoFinder[ T ]
#	super Finder[ T ]
#	private var algos: Algos
#	private var collection: Collection[ T ]
#	init ( c: Collection[ T ] ) do
#		self.collection = c
#		self.algos = new Algos
#	end
#	redef fun find( e ) do
#		#TODO implement
#	end
#end
