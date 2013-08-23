class Array
  def safe_transpose
    result = []
    max_size = self.max { |a,b| a.size <=> b.size }.size
    puts "max_size is #{max_size}"
    max_size.times do |i|
    	puts "i is #{i}"
      result[i] = Array.new
      puts "result[i] after initialization is #{result[i].inspect}"
      self.each_with_index { |r,j| result[i][j] = r[i] }
    end
    puts "Result is: \n #{result.inspect}"
    result
  end
end

array =  [[:a, 1, 2], [:b, 4, 5, 6], [:c, 7, 8, 9, 3], [:d, 10, 11, 12], [:e, 16, 17, 18]]

puts "Once through: \n"
array.safe_transpose
puts "\n\n Twice through: \n"
array.safe_transpose.safe_transpose