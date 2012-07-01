import red_black_trees

#class SomeFunctor
#	super UnaryProctor[ Int ]
#	redef fun call( e ) do
#		print e + 4
#	end
#end

#var a = new Array[ nullable Int ].with_capacity( 10 )
#for i in [ 0 .. 10 [ do
#	a[ i ] = i
#end

#var algos = new Algos()
#var iter = algos.find( a.iterator, 4 )
#print iter.item.as( not null )
#algos.find( iter, 3 )
#if iter.is_ok then print "ok" else print "not ok"
#algos.for_each( a.iterator, new SomeFunctor )
#var tree = new TreeMultiSet[ Int ]
#algos.copy( a.iterator, new SortedInserter[ Int ]( tree ) )
#print "TREE"
#var tree_iter = tree.iterator
#while tree_iter.is_ok do
#	print tree_iter.item.as( not null )
#	tree_iter.next
#end

class MyList[ T ]
	super BackInsertable[ T ]
	private var l: List[ T ]
	
	init() do 
		l = new List[ T ]
	end
	redef fun push( e: T ) do
		l.push( e )
	end
	fun join( sep: String ): String do
		return l.join( sep )
	end
end

var set = new TreeSet[ Int ]
for i in [ 0 .. 100 [ do
	set.insert( i )
end
print "size: {set.interval.size}"
print "count: {set.interval.count( 50, new DefaultEquals[ Int, Int ]() )}"
var list = new MyList[ Int ]
set.interval.copy( new BackInserter[ Int ]( list ) )
print "copy: " + list.join( ", " )
