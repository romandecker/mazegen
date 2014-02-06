class Coordinates

  attr_accessor :x, :y

  def initialize( x, y = nil )
  
    if x.kind_of?( Array )
      @x, @y = x[0], x[1]
    else
      @x, @y = x, y
    end
  end
  
  def to_s
    return "(#{@x},#{@y})"
  end
  
  def ==(o)
    o.class == self.class && o.state == state
  end
  alias_method :eql?, :==
  
  protected
  def state
    [@x, @y]
  end
  
end

class Node
  
  attr_accessor :sym
  attr_accessor :coords
  attr_accessor :parent
  attr_accessor :g
  attr_accessor :h
  
  def initialize( sym, coords, g = nil, h = nil )
    @sym = sym
    @coords = coords
    @g = g
    @h = h
  end
  
  def walkable?
    [:open, :unbuildable, :start, :goal].include? @sym
  end
  
  def goal?
    return sym == :goal
  end
  
  def f
    g + h
  end
  
  def ==(o)
    o.class == self.class && o.coords == self.coords
  end
  
  alias_method :eql?, :==
  
  def to_s
    ch = case @sym
            when :open then ' '
            when :unbuildable then '.'
            when :start then 'S'
            when :goal then 'G'
            when :tower then 't'
            else 'W'
         end
  
    "#{ch}@#{@coords} g: #{g}, h: #{h}, f: #{f}"
  end
  
end

class Map

  attr_reader :map

  def goal_location
    @goal
  end
  
  def start_location
    @start
  end

  def initialize( map )
    @map = map
    
    @goal = find :goal
    @start = find :start
    
  end
  
  def initialize_copy( source )
    super
    @map = source.map.dup
  end

  def self.load( file )
    map = []
  
    File.open( file, 'r' ) do |f|
      f.each_line do |line|    
        row = []
        line.strip.split(//).each do |ch|
          row << case ch.upcase
                    when ' ' then :open
                    when '.' then :unbuildable
                    when 'S' then :start
                    when 'G' then :goal
                    when 'T' then :tower
                    else :wall
                  end
        end
        
        map << row
      end
    end
    
    return Map.new( map )
  end
  

  def solve

    
    initial = current = Node.new( :start, @start, 0, manhattan( @start, @goal ) )
    open = [current]
    closed = []
    
    until open.empty? do
    
      open.delete current
      closed << current
      
      ns = neighbors( current )
      ns.each do |neighbor|
        if neighbor.walkable? and !closed.include?( neighbor ) then

          neighbor.parent = current
          if !open.include?( neighbor ) then
            
            #puts "Added #{neighbor} because it is walkable"
            open << neighbor
            
            return make_path( initial, neighbor ) if neighbor.goal?
          else
            old = open.find{ |n| n.coords.x == neighbor.coords.x and n.coords.y == neighbor.coords.y }
            if neighbor.g < old.g then
              open.delete old
              open << neighbor
              
              return make_path( initial, neighbor ) if neighbor.goal?
            end
          end

        end
      end
      
      current = open.min_by{ |n| n.f }
    end
    
    return nil

  end


  def to_s
    ret = ""
    
    @map.each do |row|
      row.each do |cell|
        ret << case cell
          when :open then ' '
          when :unbuildable then '.'
          when :start then 'S'
          when :goal then 'G'
          when :tower then 'T'
          else 'W'
        end
      end
      ret << "\n"
    end
    
    return ret
  end

  def at( p, y = nil )
    unless p.kind_of? Coordinates then
      p = Coordinates.new( p, y )
    end
        
    if p.x >= @map.length then return nil end
    if p.y >= @map[p.x].length then return nil end
    
    return @map[p.x][p.y]
  end
  
  def set( coords, sym )
    
    @map[coords.x][coords.y] = sym
  end
  
  def find_all( sym )
    ret = []
  
    @map.each_with_index do |line, i|
      line.each_with_index do |c, j|
        ret << Coordinates.new( i, j ) if c == sym
      end
    end
    
    return ret
  end
  
  
  
  private
  def find( sym )
    
    @map.each_with_index do |line, i|
      j = line.find_index sym
      return Coordinates.new( i, j ) if j
    end
    
    return nil
  end

  def neighbors( node )
    
    ret = []
    
    #ret << create_node( node.coords.x - 1, node.coords.y - 1, node.g + 1 )
    ret << create_node( node.coords.x - 1, node.coords.y, node.g + 1 )
    #ret << create_node( node.coords.x - 1, node.coords.y + 1, node.g + 1 )
    ret << create_node( node.coords.x, node.coords.y - 1, node.g + 1 )
    ret << create_node( node.coords.x, node.coords.y + 1, node.g + 1 )
    #ret << create_node( node.coords.x + 1, node.coords.y - 1, node.g + 1 )
    ret << create_node( node.coords.x + 1, node.coords.y, node.g + 1 )
    #ret << create_node( node.coords.x + 1, node.coords.y + 1, node.g + 1 )
    
    return ret.compact
  end
  
  def create_node( x, y, g )
    
    sym = self.at( x, y )
    
    if sym.nil?
      return nil
    else
      return Node.new( sym, Coordinates.new(x, y), g, manhattan( Coordinates.new(x,y), @goal ) )
    end
  end

  def manhattan( from, to )
    (from.x - to.x).abs + (from.y - to.y).abs
  end
  
  def make_path( parent, leaf )
    
    ret = []
    
    current = leaf
    while( current != parent && !current.nil? )
      ret << current
      current = current.parent
    end
    
    ret << parent unless current.nil?
    
    return ret.reverse
  end


end