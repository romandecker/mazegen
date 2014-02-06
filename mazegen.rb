require 'set'
require './map.rb'

def rand_n(n, max)
    randoms = Set.new
    loop do
        randoms << rand(max)
        return randoms.to_a if randoms.size >= n
    end
end

def place_towers( map, n )

  ret = Marshal.load( Marshal.dump( map ) )
  
  buildable = ret.find_all( :open )
  positions = rand_n( n, buildable.length )
  
  positions.each do |pos|
    coords = buildable[pos]
    ret.set( coords, :tower )
  end
  
  return ret
end

def fitness( map )
  path = map.solve
  
  if path.nil?
    return -1.0/0.0
  else
    return -path.length
  end
end



map = Map.load ARGV[0]
n = ARGV[1].to_i

puts map
puts "Start: #{map.start_location}"
puts "Goal: #{map.goal_location}"

puts "Placing #{n} towers..."
place_towers( map, n )

generation = []
best_fitness = -1.0/0.0
best = map

1000.times do
  solution = place_towers( map, n )
    
  f = fitness( solution )
  generation << [f, solution]
  
  if f > best_fitness then
    best = solution
  end
end

puts "Best solution:"

path = best.solve
lines = best.to_s.split( /\n/ )

path.slice( 1, path.length - 2 ).each do |node|
  lines[node.coords.x][node.coords.y] = 'x'
end

puts lines.join( "\n" )
