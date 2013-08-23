require_relative 'nokogiri_test'
require_relative 'output'

# Get a Nokogiri::HTML:Document for the page we’re interested in...

# Base URL used to build Google search queries
# BASE_URL = "http://www.google.com/search?q="

# Hardcoded Query List - now get this through INPUT
# query_list = "bed, coffee table, cushion, furniture outlet, furniture, lounge chair, pillow, sofas, table, vase, wall art"

# INPUT
puts "Please enter the searh terms whose ads you would like to analyze."
puts "Keywords should be separated by commas."
puts "For example: beds, coffee tables, cushions, egg-timer"
query_list = gets.chomp

queries = create_search_queries(query_list)

# Parse Company name from target URL in ad
# Takes an ad as a parameter, formatted as an array, split by line
def find_advertiser(ad)
	target_url = ad[2]
	split_url = target_url.split(".")
	if split_url.length == 3
		advertiser = split_url[1]
	elsif split_url.length == 2
		advertiser = split_url[0]
	else
		advertiser = /(www\.)?(.*)\./.match(target_url)[2]
	end
	return advertiser
end

# Create a hash of ADS by SEARCH QUERY
ads_by_query = {}
queries.each do |query|
	page = get_page(query)
	ads_by_query[query] = get_all_ads(page)
end

# Create a hash of ADS by COMPANY
# Create a multi-dimensional array of ADS by COMPANY and QUERY
all_ads = {}
ads_by_company = {}
ads_by_query.each do |query, ads|
	ads.each do |ad|
		advertiser = find_advertiser(ad)
		# Add advertisement to hash of ADS by COMPANY		
		if !ads_by_company[advertiser]
			ads_by_company[advertiser] = [].push(ad)
		else
			ads_by_company[advertiser].push(ad)
		end
		# Add advertisement with query & company info to hash with array as key
		all_ads[[query, advertiser]] = ad
	end
end


time = Time.new

file_base = "#{time.year}-#{time.month}-#{time.year}--#{time.hour}-#{time.min}------"

file_name_1 = file_base + "ads_by_company.csv"
file_name_2 = file_base + "ads_by_query.csv"
file_name_3 = file_base + "company-x-query.csv"

write_to_simple_csv(file_name_1, ads_by_company)
write_to_simple_csv(file_name_2, ads_by_query)
write_to_2d_csv(file_name_3, all_ads)
puts "Successfully written!"

=begin
# Test ads_by_company output
ads_by_company.each do |company, ad_array|
	puts "------------------#{company.upcase}------------------"
	ad_array.each do |ad|
		puts ad
	end
	puts "\n"
end

# Test multi-dimensional array of all ads
all_ads[0..20].each do |ad_with_info|
	query = ad_with_info[0]
	advertiser = ad_with_info[1]
	ad = ad_with_info[2]
	puts "Query: #{query}"
	puts "Advertiser: #{advertiser.capitalize}"
	puts "Ad: \n#{ad}"
end
=end

