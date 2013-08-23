require 'csv'

HOME = "/Users/casey/Dropbox/GoogleScraper/output/"
filename = ""

class Array
	def safe_transpose
		result = []
		max_size = self.max { |a, b| a.size <=> b.size }.size
		max_size.times do |i|
			result[i] = Array.new
			self.each_with_index { |r, j| result[i][j] = r[i] }
		end
		result
	end
end

# Create CSV file from a hash of ads
def write_to_simple_csv(filename, data)
	file = filename
	data_for_csv = prep_hash_for_csv(data)
	CSV.open(HOME + file, "wb") do |csv|
		data_for_csv.each do |line|
			csv << line
		end
	end
end

# Data is in Hash - put it into an array with data aligned vertically for writing to CSV
def prep_hash_for_csv(data_hash)
	big_array = []
	data_hash.each do |key, ads|
		ad_array = [].push(key)
		ads.each do |ad|
			ad_string = ad[0] + "\r" + ad[1] + "\r" + ad[2]
			ad_array.push(ad_string)
		end
		big_array.push(ad_array)
	end
	output_array = big_array.safe_transpose
	return output_array
end

# Create CSV file listing matrix of ads by company by query
def prep_2d_hash_for_csv(all_ads)
	# Initialize output array
	output_array = []
	output_array[0] = []

	# Create empty space at top left of the graph
	output_array[0].push("")

	# Create empty array to hold all advertisers
	advertisers = []

	# Create maps for advertiser and query representing their 
	# respective column / row number
	advertiser_row_map = {}
	query_column_map = {}

	all_ads.each_with_index do |(key, value), index|
		query = key[0]
		advertiser = key[1]
		ad = value

		# Create the top array with a list of queres & mark it in row map
		output_array[0].push(query)

		# Create a list of all the advertisers
		advertisers.push(advertiser)
	end

	advertisers.uniq!
	output_array[0].uniq!

	output_array[0].each_with_index do |query, index|
		query_column_map[index] = query
	end

	# Create empty arrays (rows) in output_array
	(advertisers.length).times do |i|
		output_array.push([])
	end

	# Add advertisers to each of the sub-arrays (labeling rows)
	output_array.each_with_index do |sub_array, index|
		if sub_array[0]
			next
		else
			# Initialize first column of data with list of advertisers
			# Also mark it down in the query_row_map
			advertiser = advertisers[index-1]
			sub_array.push(advertiser)
			advertiser_row_map[index] = advertiser
		end
	end

	# Populate 2d array (table) with empty data: ""
	number_of_columns = output_array[0].length
	output_array.each do |sub_array|
		until sub_array.length == number_of_columns
			sub_array.push("")
		end
	end

	# Populate 2d array with data
	# If company/query does not have a match, input ""
	output_array.each_with_index do |sub_array, row_index|
		sub_array.each_with_index do |cell, column_index|
			query = query_column_map[column_index]
			advertiser = advertiser_row_map[row_index]

			if all_ads[[query, advertiser]]
				ad = all_ads[[query, advertiser]]
				ad_string = ad[0] + "\r" + ad[1] + "\r" + ad[2]
				output_array[row_index][column_index] = ad_string
			else
				next
			end
		end
	end

	# Return 2d hash, representing a table of ads, query x advertiser
	return output_array
end

def write_to_2d_csv(filename, all_ads)
	file = filename
	data_for_csv = prep_2d_hash_for_csv(all_ads)
	CSV.open(HOME + file, "wb") do |csv|
		data_for_csv.each do |line|
			csv << line
		end
	end
end

