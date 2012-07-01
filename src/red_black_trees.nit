import results
import inserters
import iterators
import functions
import intervals
import data_structures

#Class of red black tree nodes. Basically, in addition to usual
#tree pointers the node holds a color, which is either red or black.
#Since a red black tree is binary, each node has a pointer to its left
#and right child. Sometimes, the algorithms require we extract information
#requiring the parent of a node, therefore a parent pointer is also
#maintained.
private class RBTreeNode[ T ]
	#The node's element.
	private var element: T
	#A boolean indicating whether the node is red (true) or black (false)
	private var painted_red: Bool
	#The left child.
	private var left: nullable RBTreeNode[ T ]
	#The right child.
	private var right: nullable RBTreeNode[ T ]
	#The parent.
	private var parent: nullable RBTreeNode[ T ]

	#Creates a red node with the provided element.
	init( element: T ) do
		self.painted_red = true
		self.element = element
	end	
	#Paints the node red.
	fun paint_red() do
		self.painted_red = true
	end
	#Paints the node black.
	fun paint_black() do
		self.painted_red = false
	end	
	#Returns true if the node is black, false if it is red.
	fun is_black(): Bool do
		return not is_red()
	end
	#Returns true if the node is red, false if it is black.
	fun is_red(): Bool do
		return self.painted_red
	end
	#Returns true if the parent of the node has been set, false otherwise.
	fun has_parent(): Bool do
		return self.parent != null
	end
	#Returns true if the node has AT LEAST one child, false otherwise.
	fun has_child(): Bool do
		return has_left() or has_right()
	end
	#Returns true if the node has NO children, false if one exists.
	fun is_leaf(): Bool do
		return not has_left and not has_right
	end
	#Returns true if the node has a left child, false otherwise.
	fun has_left(): Bool do
		return self.left != null
	end
	#Returns true if the node has a right child, false otherwise.
	fun has_right(): Bool do
		return self.right != null
	end
	#Returns true if the node is the left child of its parent. If it is the right
	#child or if it simply does not have a parent, then false is returned.
	fun is_left(): Bool do
		return self.parent != null and self == self.parent.left
	end
	#Returns true if the node is the right child of its parent. If it is the left
	#child or if it simply does not have a parent, then false is returned.
	fun is_right(): Bool do
		return self.parent != null and self == self.parent.right
	end	
	#Fetches the uncle, if it exists. Returns null otherwise.
	fun uncle(): nullable RBTreeNode[ T ] do
		var gp = grandparent()
		if gp == null then return null
		if self.parent.is_left then
			return gp.right
		else 
			return gp.left
		end
	end
	#Fetches the grandparent, if it exists. Returns null otherwise.
	fun grandparent(): nullable RBTreeNode[ T ] do
		if self.parent != null then
			return self.parent.parent
		else
			return null
		end
	end
	#Fetches the sibling of the current node. Returns null if none exists.
	fun sibling(): nullable RBTreeNode[ T ] do
		if is_left then 
			return self.parent.right
		else if is_right then
			return self.parent.left
		end
		return null			
	end
	#Fetches the farthest node possible following only the left pointers.
	#Stops when no left child is available. Therefore, if the receiver of this
	#method has no left child, then the receiver is returned.
	fun deepest_left(): RBTreeNode[ T ] do
		var res = self.as( nullable RBTreeNode[ T ] )
		while res.has_left do
			res = res.left
		end
		return res.as( not null )
	end
	#Same as deepest left, but following the right pointers instead.
	fun deepest_right(): RBTreeNode[ T ] do
		var res = self.as( nullable RBTreeNode[ T ] )
		while res.has_right do
			res = res.right
		end
		return res.as( not null )
	end
end

class RBTreePosition[ T ] super Position[ T ]
	redef type Compared: RBTreePosition[ T ]
	
	private var node: nullable RBTreeNode[ T ]
	private init inplace( n: nullable RBTreeNode[ T ] ) do
		self.node = n
	end
	private init invalid() do
		self.node = null
	end	
	redef fun is_ok(): Bool do
		return self.node != null
	end
	redef fun item(): T do
		return self.node.element
	end
	redef fun equals( rhs: Compared ): Bool do
		return self.node == rhs.node
	end
end

#Bidirectional iterator.
class RBTreeBiIterator[ T ]
	super RBTreePosition[ T ]
	super BidirectionalIter[ T ]
	#Creates an iterator that start on the specified node.
	private init inplace( node: nullable RBTreeNode[ T ] ) do
		self.node = node
	end
	redef fun next() do
		if self.node.is_right and not self.node.has_right then
			while self.node.is_right do
				self.node = self.node.parent
			end
			self.node = self.node.parent
		else if node.has_right then
			node = node.right.deepest_left
		else 
			node = node.parent
		end
	end
	#Same as calling next on a reverse iterator.
	redef fun previous() do
		if self.node.is_left and not self.node.has_left then
			while self.node.is_left do
				self.node = self.node.parent
			end
			self.node = self.node.parent
		else if node.has_left then
			node = node.left.deepest_right
		else 
			node = node.parent
		end
	end
	#Returns a newly created reverse iterator starting on the same position.
	redef fun reverse(): RBTreeRIterator[ T ] do
		return new RBTreeRIterator[ T ].inplace( self.node )
	end
end

#Reverse view of the iterator.
class RBTreeRIterator[ T ] 
	super RBTreePosition[ T ]
	super BidirectionalIter[ T ]
	#Creates an iterator that start on the specified node.
	private init inplace( node: nullable RBTreeNode[ T ] ) do
		self.node = node
	end
	redef fun next() do
		if self.node.is_left and not self.node.has_left then
			while self.node.is_left do
				self.node = self.node.parent
			end
			self.node = self.node.parent
		else if node.has_left then
			node = node.left.deepest_right
		else 
			node = node.parent
		end
	end	
	redef fun previous() do
		if self.node.is_right and not self.node.has_right then
			while self.node.is_right do
				self.node = self.node.parent
			end
			self.node = self.node.parent
		else if node.has_right then
			node = node.right.deepest_left
		else 
			node = node.parent
		end
	end	
	redef fun reverse(): RBTreeBiIterator[ T ] do
		return new RBTreeBiIterator[ T ].inplace( self.node )
	end
end

class RBTreeInterval[ T ] super SortedInterval[ T ]
	redef type PosType: RBTreePosition[ T ]
	redef type IterType: RBTreeBiIterator[ T ]
	
	redef fun iterator_on( pos ) do
		return new RBTreeBiIterator[ T ].inplace( pos.node )
	end
	redef fun invalid_pos(): PosType is abstract	
end

#Main class of the module. This class models a red black tree that can handle duplicate values.
#It is designed to be used as either a base or an embedding solution for other trees that models
#sets, multisets, maps and multimaps.
#T is the element type of the tree. A is the access type of the tree. Namely, A stands for T in sets
#but for the key in maps, whereas T stands for the pair.
abstract class RBTree[ T, A ]
	super SortedInsertable[ T ]
	super DataStructure[ T ]
	#The tree root
	private var root: nullable RBTreeNode[ T ]
	#The comparator object, accessible but not settable.
	var comparator: Comparator[ A, A ]
	#Creates a new red black tree with the equivalence comparator
	init() do
		self.root = null
		self.comparator = new EquivalenceComparator[ A, A ]
	end
	#Creats a new red black tree with the given comparator.
	init with_comparator( c: Comparator[ A, A ] ) do
		self.comparator = c
	end	
	#Adds the element to the tree. Rebalancing might be triggered. If the element
	#already exists, then it is placed as a right child of the rightmost duplicate.
	redef fun insert( element: T ) do
		insert_new_node( element )
	end
	#Removes at the location indicated by the iterator. The iterator is moved to the next
	#element according to its iteration semantic.
	#NOTE: Results of removing on an already invalidated iterator are undefined.
	#Removing on an invalid iterator does nothing.
	fun remove_at( iter: RBTreeBiIterator[ T ]): RBTreeBiIterator[ T ] do
		if not iter.is_ok then return iter
		var n = iter.node
		var r = find_replacement( n.as( not null ) )
		#We move the iterator to its next value in its order.
		iter.next
		#Move the replacement value to the removed one.
		if r != n then 
			n.element = r.element
			#If it turns out that the next value if the replacement, then
			#we reset the iterator on its previous node.
			if iter.node == r then iter.node = n
		end
		#Delete the replacement node.
		delete_node( r )
		return iter
	end	
	#Removes all element from the tree and puts it in an empty state. Doing this
	#invalidates all iterator and failure to acknowledge so is a gamble to enter
	#the world of undefined behavior.
	fun clear() do
		self.root = null
	end
	#Returns true if the tree is empty, false otherwise.
	fun is_empty(): Bool do
		return self.root == null
	end
	#Returns the number of elements.
	fun size(): Int do
		if is_empty then return 0
		var count = 0
		var nodes_to_visit = new List[ nullable RBTreeNode[ T ] ]
		nodes_to_visit.push( self.root )
		while not nodes_to_visit.is_empty do
			var n = nodes_to_visit.first
			nodes_to_visit.shift
			count += 1
			if n.has_left then nodes_to_visit.push( n.left )
			if n.has_right then nodes_to_visit.push( n.right )
		end
		return count
	end
	#Returns true if the tree holds at least one occurrence of the given element, false otherwise.
	fun has( e: A ): Bool do
		return find_node( e ) != null
	end	
	
	#-------------------------------
	#Iterator methods.
	#-------------------------------
	
	#Returns an iterator that iterates in ascending order.
	redef fun iterator(): RBTreeBiIterator[ T ] do
		return new RBTreeBiIterator[ T ].inplace( lowest )
	end
	#Returns an iterator that iterates in descending order.
	fun reverse_iterator(): RBTreeRIterator[ T ] do
		return new RBTreeRIterator[ T ].inplace( highest )
	end
#	redef fun interval(): Interval[ T ] do
#		return new RBTreeInterval[ T ].between( lowest, highest )
#	end
	
	fun lowest(): RBTreePosition[ T ] do
		if is_empty then return new RBTreePosition[ T ].invalid
		return new RBTreePosition[ T ].inplace( self.root.deepest_left )
	end
	
	fun highest(): RBTreePosition[ T ] do
		if is_empty then return new RBTreePosition[ T ].invalid
		return new RBTreePosition[ T ].inplace( self.root.deepest_right )
	end


	#Returns an iterator on the first encountered occurrence of the
	#element. The iterator might be invalid if no such element exists.
	fun find( a: A ): RBTreeBiIterator[ T ] do
		return new RBTreeBiIterator[ T ].inplace( find_node( a ) )
	end
	#Returns an iterator on either the element or the previous in
	#order. Returns an invalid iterator if no such element exists.
	fun floor( a: A ): RBTreeBiIterator[ T ] do
		return new RBTreeBiIterator[ T ].inplace( floor_node( a ) )
	end
	#Returns an iterator on either the element or the next in
	#order. Returns an invalid iterator if no such element exists.
	fun ceiling( a: A ): RBTreeBiIterator[ T ] do
		return new RBTreeBiIterator[ T ].inplace( ceiling_node( a ) )
	end
	
	#-------------------------------
	#Utility methods.
	#-------------------------------
	private	fun floor_node( a: A ): nullable RBTreeNode[ T ] do
		var n = self.root		
		var floor = n
		var floor_found = false
		while n != null and not floor_found do 
			if is_lower( a, access_key( n ) ) then
				if n.has_left then n = n.left else floor_found = true
			else if is_lower( access_key( n ), a ) then
				floor = n
				if n.has_right then n = n.right else floor_found = true
			else
				floor = n
				floor_found = true
			end
		end
		return floor
	end
	
	private fun ceiling_node( a: A ): nullable RBTreeNode[ T ] do
		var n = self.root		
		var ceiling = n
		var ceiling_found = false
		while n != null and not ceiling_found do 
			if is_lower( a, access_key( n ) ) then
				ceiling = n				
				if n.has_left then n = n.left else ceiling_found = true
			else if is_lower( access_key( n ), a ) then
				if n.has_right then n = n.right else ceiling_found = true
			else
				ceiling = n
				ceiling_found = true
			end
		end
		return ceiling
	end
	
	private fun access_key( n: RBTreeNode[ T ] ): A do
		return n.element
	end	
	
	#Returns true if the comparator returns 0.
	private fun is_equivalent( lhs: A, rhs: A ): Bool do
		return self.comparator.call( lhs, rhs ) == 0
	end
	
	#Returns true if lhs < rhs, as provided by the comparator.
	private fun is_lower( lhs: A, rhs: A ): Bool do
		return self.comparator.call( lhs, rhs ) < 0
	end
	#Emplaces the node to the specified location. Nodes linking on the destination
	#are updated properly to link on the moved node. Works if the node is null.
	private fun move_node_to( n: nullable RBTreeNode[ T ], dest: RBTreeNode[ T ] ) do
		if dest == self.root then
			self.root = n
	 	else if dest.is_right then 
			dest.parent.right = n
		else 
			dest.parent.left = n
		end
		if n != null then n.parent = dest.parent
	end	
	#Returns the node holding the replacement value of the node, or the node itself
	#if it does not have two children. If it does, then this function return the
	#in-order predecessor (rightmost of the left subtree).
	private fun find_replacement( n: RBTreeNode[ T ] ): RBTreeNode[ T ] do
		if not n.has_left or not n.has_right then return n
		#If we made it here, the node has two children.
		return n.left.deepest_right
	end	
	#Returns the first node associated with the element found, null
	#if no such element exists in the tree.
	private fun find_node( a: A ): nullable RBTreeNode[ T ] do
		var n = self.root
		var node_found = false
		while not node_found and n != null do
			if is_lower( a, access_key( n ) ) then
				#If there is no left child, then current node becomes null.
				n = n.left				
			else if is_lower( access_key( n ), a ) then
				n = n.right
			#Equivalence, if !( x < y ) and !( y < x ) then x == y.
			else if is_equivalent( a, access_key( n ) ) then
				node_found = true			
			else
				assert false else print "Unknown relation between {n} and {access_key( n )}"
			end
		end
		return n
	end
	
	private fun rotate_left( top: nullable RBTreeNode[ T ] ) do
		var new_top = top.right
		#Move the new top's left sub tree to the previous
		#top right's subtree.
		top.right = new_top.left
		if null != top.right then top.right.parent = top
		#Replace top for new top.
		if top.has_parent then
			if top.is_left then
				top.parent.left = new_top
			else
				top.parent.right = new_top
			end
			new_top.parent = top.parent
		else
			self.root = new_top
			self.root.parent = null
		end
		top.parent = new_top
		new_top.left = top
	end
	
	private fun rotate_right( top: nullable RBTreeNode[ T ] ) do
		var new_top = top.left
		#Move the new top's right sub tree to the previous
		#top left's subtree.
		top.left = new_top.right
		if null != top.left then top.left.parent = top
		#Replace top for new top.
		if top.has_parent then
			if top.is_left then
				top.parent.left = new_top
			else
				top.parent.right = new_top
			end
			new_top.parent = top.parent
		else
			self.root = new_top
			self.root.parent = null
		end
		top.parent = new_top
		new_top.right = top
	end
	
	private fun is_valid_node( node: nullable RBTreeNode[ T ] ): Bool do
		return node != null
	end
	
	private fun find_insertion_node( a: A ): nullable RBTreeNode[ T ] do
		if self.root == null then return null	
		var n = self.root
		var location_found = false
		while not location_found do
			if is_lower( a, access_key( n.as( not null ) ) ) then
				if n.has_left() then
					n = n.left
				else 
					location_found = true
				end
			else 
				if n.has_right() then
					n = n.right
				else
					location_found = true					
				end
			end
		end
		return n
	end
	
	private fun insert_node_under( n: RBTreeNode[ T ], p: nullable RBTreeNode[ T ] ) do
		if p == null then return
		if is_lower( access_key( n), access_key( p.as( not null ) ) ) then
			p.left = n
		else
			p.right = n
		end
		n.parent = p
	end
	
	private fun insert_new_node( element: T ) do
		var new_node = new RBTreeNode[ T ]( element )
		insert_node_under( new_node, find_insertion_node( access_key( new_node ) ) )
		#Root insertion
		if self.root == null then self.root = new_node
		insert_rebalance( new_node )		
	end
	
	#Creates a red node initialized with the element.
	private fun create_node( element: T ): RBTreeNode[ T ] do
		return new RBTreeNode[ T ]( element )
	end
	#Method for testing if a node is red. Returns true if and only if
	#the node if not null and is red.
	private fun is_red( n: nullable RBTreeNode[ T ] ): Bool do
		return n != null and n.is_red
	end
	#Method for testing if a node is black. Returns true either if
	#the node is null (a leaf) or if the node is black.
	private fun is_black( n: nullable RBTreeNode[ T ] ): Bool do
		return n == null or n.is_black
	end
		
	#-------------------------------
	#Deletion methods.
	#-------------------------------
	
	#Assumes the node has at most one child.
	private fun delete_node( n: RBTreeNode[ T ] ): nullable RBTreeNode[ T ] do
		assert not ( n.has_left and n.has_right )
		
		#If it has no children.
		if n.is_leaf then
			#Rebalancing is only necessary when removing a non root black leaf.
			if n.is_black and self.root != n then delete_rebalance( n )
			#Removing a red node without children has no effect on the tree.
			#Same goes for removing the root without children.
			move_node_to( null, n )
			return null
		end
		#Since the node has only one child, the node can only be black.
		assert n.is_black
		var child: RBTreeNode[ T ]
		if n.has_left then child = n.left.as( not null ) else child = n.right.as( not null )	
		#And the child can only be red.
		assert child.is_red
		move_node_to( child, n )
		#Therefore, all we have to do to correct the imbalance is to paint the child black.
		child.paint_black
		return child
	end
	
	#assumption: n is black and therefore n has a sibling (non root case)
	private fun delete_rebalance( n: RBTreeNode[ T ] ) do
		assert n.is_black
		if self.root == n then 
			delete_rebalance_root( n )
			return
		end
		if is_black( n.parent ) then
			delete_rebalance_black_parent( n )
		else
			delete_rebalance_red_parent( n )
		end
	end
	
	private fun delete_rebalance_root( n: RBTreeNode[ T ] ) do
		#Do nothing
	end
	
	#Since n is black, n has a sibling and it is black since p is red.
	private fun delete_rebalance_red_parent( n: RBTreeNode[ T ] ) do
		assert n.is_black
		assert n.parent.is_red
		assert n.sibling.is_black
		var p = n.parent.as( not null )
		var s = n.sibling.as( not null )
		if s.is_right then
			if is_red( s.left ) then
				p.paint_black
				rotate_right( s )
			end
			rotate_left( p )
		else
			if is_red( s.right ) then
				p.paint_black
				rotate_left( s )
			end
			rotate_right( p )
		end
	end
	
	private fun delete_rebalance_black_parent( n: RBTreeNode[ T ] ) do
		assert n.is_black
		assert n.parent.is_black
		var p = n.parent.as( not null )
		var s = n.sibling.as( not null )
		
		if is_red( s ) then
			s.paint_black
			p.paint_red
			if n.is_left then
				rotate_left( p )
			else 
				rotate_right( p )
			end
			delete_rebalance_red_parent( n )
			return
		end
		#P is black, N is black and S is black. What solution we use depends on
		#the children of S.
		#If both children are black, then we cannot use any of its children to rebalance
		#the tree. So we have to rebalance going upwards, rebalancing first the current
		#subtree.
		if is_black( s.left ) and is_black( s.right ) then
			s.paint_red
			delete_rebalance( p )
			return
		end
		#If only one child of S is red.
		if s.is_left and is_black( s.left ) then
			s.right.paint_black
			rotate_left( s )
			#The new S is black and so is its left child.
			s = n.sibling.as( not null )
		else if s.is_right and is_black( s.right ) then
			s.left.paint_black
			rotate_right( s )
			#The new S is black and so is its right child.
			s = n.sibling.as( not null )
		end
		#We now have P is black, S is black and one of its children is aligned with P.
		#In the case where we had two red children, then one will be painted black
		#and the other one is inherited by p.
		if s.is_left then
			s.left.paint_black
			rotate_right( p )
		else 
			s.right.paint_black
			rotate_left( p )
		end
	end
	
	
	
	#-------------------------------
	#Insertion methods.
	#-------------------------------
	
	#To be called on the newly created node for the new inserted element.
	private fun insert_rebalance( n: RBTreeNode[ T ] ) do
		assert n.is_red
		#If we just inserted the root, then the it only need to be painted
		#black.
		if self.root == n then 
			insert_rebalance_root( n )
			return
		end
		var p = n.parent.as( not null )
		#Adding a red node under a black node threatens no property.
		if p.is_black then 
			insert_rebalance_black_parent( n )
			return
		end
		#The uncle might be null.
		var u = n.uncle
		#But not the grandparent, since the parent is red.
		var gp = n.grandparent.as( not null )
		#The uncle is black (or null)
		if is_black( u ) then 
			insert_rebalance_black_uncle( n )
			return
		end
		insert_rebalance_red_uncle( n )
	end
	
	private fun insert_rebalance_root( n: RBTreeNode[ T ] ) do
		n.paint_black
	end
	
	private fun insert_rebalance_black_parent( n: RBTreeNode[ T ] ) do
		#Do nothing.
	end
	#Assumes that the parent is red.
	private fun insert_rebalance_black_uncle( n: RBTreeNode[ T ] ) do
		var p = n.parent.as( not null )
		#The uncle is black and the parent is red.
		#We start by placing the both of them such that they follow
		#the same direction from the root.
		if n.is_right and p.is_left then
			rotate_left( p )
			n = p
			p = n.parent.as( not null )
		else if n.is_left and p.is_right then
			rotate_right( p )
			n = p
			p = n.parent.as( not null )
		end
		var gp = n.grandparent.as( not null )
		p.paint_black
		gp.paint_red
		if n.is_left then
			rotate_right( gp )
		else
			rotate_left( gp )
		end
	end
	#Assumes the parent is red.
	private fun insert_rebalance_red_uncle( n: RBTreeNode[ T ] ) do
		#If both the uncle and the parent is red, then we only need
		#to paint them both black, adding a black node to the path.
		#However, to rebalance things, the grandparent must be painted red,
		#though painting it might need rebalancing.
		n.parent.paint_black
		n.uncle.paint_black
		n.grandparent.paint_red
		insert_rebalance( n.grandparent.as( not null ) )
	end
end

class TreeSet[ T ]
	super RBTree[ T, T ]
	init() do super end
	
	#Inserts the element in the tree. If the element already exists, then
	#it is replaced.
	redef fun insert( e ) do
		var n = find_node( e )
		if n == null then super else n.element = e
	end		
end

class TreeMultiSet[ T ]
	super RBTree[ T, T ]
	init() do super end
	init with_comparator( c ) do super end
end

class MapEntry[ K, V ]
	var key: K
	var value: V
	init ( k: K, v: V ) do
		self.key = k
		self.value = v
	end	
end

class TreeMap[ K, V ]
	super RBTree[ MapEntry[ K, V], K ]
	init() do super end
	init with_comparator( c ) do super end
	
	#Inserts the element in the tree. If the element already exists, then
	#it is replaced.
	redef fun insert( e ) do
		var n = find_node( e )
		if n == null then super else n.element = e
	end	
	
	redef fun access_key( n ) do
		return n.element.key
	end
end

#class TreeMultiMap[ K, V ]
#	super RBTree[ MapEntry[ K, V] ]
#	
#	init() do
#		self.root = null
#		self.comparator = new MapEntryComparator[ K ]( new EquivalenceComparator[ K, K ] )
#	end
#	init with_key_comparator( kc: Comparator[ K, K ] ) do
#		self.root = null
#		self.comparator = new MapEntryComparator[ K ]( kc )
#	end
#	fun iterator_on( k: K ) do

#	end
#end

#This class exists for debug purposes. It tests that its associated
#tree respects every constraint of a red black tree. Those are the constraints
#that are checked:
#	-The root must be black
#	-Any red node's child must be black
#	-The number of black nodes in every simple path from a node towards its leaf
#	 is the same.
#	-The maximum depth of a leaf is never over twice as much as the minimum depth of a leaf.
#	-Any node's left child is either lower or equivalent. Any node's right child is either
#	 greater or equivalent.
#class RBTreeValidator[ T ]
#	private var tree: RBTree[ T ]
#	
#	init ( t: TreeMultiSet[ T ] ) do
#		self.tree = t
#	end
#	
#	fun validate(): Result do
#		if self.tree.is_empty then return new Result.valid()
#		var res = check_root
#		if not res.is_valid then return res
#		res = check_red_nodes_children
#		if not res.is_valid then return res
#		res = check_depth
#		if not res.is_valid then return res		
#		res = check_black_nodes_count	
#		if not res.is_valid then return res
#		res = check_binary_semantic
#		if not res.is_valid then return res
#		return new Result.valid
#	end
#	
#	private fun check_root(): Result do
#		if not self.tree.root.is_black then
#			return new Result.invalid( "root {self.tree.root.element} is not black" )
#		end
#		return new Result.valid()
#	end
#	
#	private fun check_red_nodes_children(): Result do
#		return check_red_node_children( self.tree.root.as( not null ) )
#	end
#	
#	private fun check_red_node_children( n: RBTreeNode[ T ] ): Result do
#		if n.is_red then
#			if n.has_left and n.left.is_red then
#				return new Result.invalid( "red node {n.element} has red left child {n.left.element}" )
#			else if n.has_right and n.right.is_red then
#				return new Result.invalid( "red node {n.element} has red right child {n.right.element}" )
#			end
#		end
#		if n.has_left then 
#			var res = check_red_node_children( n.left.as( not null ) )
#			if not res.is_valid then return res
#		end
#		if n.has_right then
#			var res = check_red_node_children( n.right.as( not null ) )
#			if not res.is_valid then return res
#		end
#		return new Result.valid()
#	end
#	
#	private fun check_black_nodes_count(): Result do
#		var res = check_node_count( self.tree.root.as( not null ) )
#		if res.is_valid then return new Result.valid else return new Result.invalid( res.message )
#	end
#	
#	private fun check_node_count( n: RBTreeNode[ T ] ): ValuedResult[ Int ] do
#		var left_count = 0
#		var right_count = 0
#		if n.has_left then 
#			var res = check_node_count( n.left.as( not null ) )
#			if not res.is_valid then return res
#			left_count = res.value
#		end
#		if n.has_right then 
#			var res = check_node_count( n.right.as( not null ) )
#			if not res.is_valid then return res
#			right_count = res.value
#		end
#		if left_count != right_count then
#			return new ValuedResult[ Int ].invalid( "{n.element} has {left_count} black nodes in its left subtree but {right_count} in its right" )
#		end
#		return new ValuedResult[ Int ].valid( left_count )
#	end
#	
#	private fun check_depth(): Result do
#		var count = 0
#		var iter = self.tree.iterator
#		while iter.is_ok do 
#			count +=1
#			iter.next
#		end
#		var max_depth = max_node_depth( self.tree.root.as( not null ) )
#		var min_depth = min_node_depth( self.tree.root.as( not null ) )
#		
#		if min_depth * 2 < max_depth then 
#			return new Result.invalid( "the tree's maximum depth {max_depth} is over twice as much as min depth {min_depth}" )
#		end
#		return new Result.valid()
#	end
#	
#	private fun max_node_depth( n: RBTreeNode[ T ] ): Int do
#		var max_depth = 1
#		var left_max_depth = 0
#		var right_max_depth = 0
#		if n.has_left then left_max_depth = max_node_depth( n.left.as( not null ) )
#		if n.has_right then right_max_depth = max_node_depth( n.right.as( not null ) )
#		if left_max_depth < right_max_depth then max_depth += right_max_depth else max_depth += left_max_depth
#		return max_depth
#	end
#	
#	private fun min_node_depth( n: RBTreeNode[ T ] ): Int do
#		var min_depth = 1
#		var left_min_depth = 0
#		var right_min_depth = 0
#		if n.has_left then left_min_depth = min_node_depth( n.left.as( not null ) )
#		if n.has_right then right_min_depth = min_node_depth( n.right.as( not null ) )
#		if left_min_depth < right_min_depth then min_depth += left_min_depth else min_depth += right_min_depth
#		return min_depth
#	end
#	
#	private fun check_binary_semantic(): Result do
#		if self.tree.is_empty then return new Result.valid
#		var nodes_to_visit = new List[ RBTreeNode[ T] ]
#		var n = self.tree.root.as( not null )
#		nodes_to_visit.push( n )
#		while not nodes_to_visit.is_empty do
#			n = nodes_to_visit.shift
#			var res = check_node_binary_semantic( n )
#			if not res.is_valid then return res
#			if n.has_left then nodes_to_visit.push( n.left.as( not null ) )
#			if n.has_right then nodes_to_visit.push( n.right.as( not null ) )						
#		end		
#		return new Result.valid
#	end
#	
#	private fun check_node_binary_semantic( n: RBTreeNode[ T ] ): Result do
#		if n.has_left and 
#			not ( self.tree.is_lower( n.left.element, n.element ) or
#				self.tree.is_equivalent( n.left.element, n.element ) ) then
#			return new Result.invalid( "{n.element} has left child {n.left.element} which violates binary search semantics")
#		else if n.has_right and
#			not ( self.tree.is_lower( n.element, n.right.element ) or 
#				self.tree.is_equivalent( n.element, n.right.element ) ) then
#			return new Result.invalid( "{n.element} has right child {n.right.element} which violates binary search semantics")		
#		end
#		return new Result.valid
#	end
#	
#	fun tree_string(): String do
#		if self.tree.is_empty then 
#			return "empty tree"
#		end
#		var res = ""
#		var nodes_to_visit = new List[ RBTreeNode[ T ] ]
#		nodes_to_visit.push( self.tree.root.as( not null ) )
#		while not nodes_to_visit.is_empty do
#			var n = nodes_to_visit.first
#			nodes_to_visit.shift
#			if self.tree.root == n then
#				res += "root: " + node_content_string( n )
#			else
#				res += "node: " + node_content_string( n )
#			end
#			if n.has_left then
#				res += " left: " + node_content_string( n.left.as( not null ) )
#				nodes_to_visit.push( n.left.as( not null ) )
#			end
#			if n.has_right then
#				res += " right: " + node_content_string( n.right.as( not null ) )
#				nodes_to_visit.push( n.right.as( not null ) )
#			end
#			res += "\n"
#		end
#		return res
#	end
#	
#	private fun node_content_string( n: RBTreeNode[ T ] ): String do
#		var res = "\{ {n.element}, "
#		if n.is_red then res += "red \}" else res += "black \}"
#		return res
#	end

#end
