require 'rubygems'
require 'nokogiri'
require 'open-uri'

# Gets the Nokogiri page object resulting from a Google query
def get_page(query)
	# FOR OFFLINE DEVELOPMENT
	# uri = BASE_URL + query + ".html"
	# page = Nokogiri::HTML(open(uri))
	
	uri = BASE_URL + query
	page = Nokogiri::HTML(open(uri).read)
	return page
end

def get_ads(page, area_id)
	# Ads on the top & side of the page have different class & id names
	# Account for naming discrepancies
	base_id = ""
	if area_id == "top"
		area = "tads"
		base_id = "pa"
	elsif area_id == "side"
		area = "rhs_block"
		base_id = "an"
	else
		raise "get_ads method error - argument should be either 'top' or 'side'"
	end

	# Harvest ad copy
	ad_copies = page.css("div##{area} span.ac")

	# Harvest display links
	display_links = page.css("div##{area} div.kv")

	# Harvest headlines
	# Headline has ID that increments by one for each advertisement
	# Thus needs a slightly more complex solution to Harvest
	headlines = []
	counter = 1

	until headlines.length == ad_copies.length do 
		id = base_id + counter.to_s
		headlines.push(page.css("div##{area} a##{id}"))
		counter += 1
	end

	# Put ads into an array
	ads = []
	headlines.each_with_index do |headline, index|
		headline = headline.text
		ad_copy = ad_copies[index].text
		display_link = display_links[index].text
		ads.push([headline, ad_copy, display_link])
	end
	return ads
end

def get_top_ads(page)
	top_ads = get_ads(page, "top")
	return top_ads
end

def get_side_ads(page)
	side_ads = get_ads(page, "side")
	return side_ads
end

def get_all_ads(page)
	top_ads = get_top_ads(page)
	side_ads = get_side_ads(page)
	ads = top_ads + side_ads
	return ads
end

def create_search_queries(query_string)
	queries = query_string.split(", ").map {|query| query.gsub(" ", "+")}
	return queries
end

# Get a Nokogiri::HTML:Document for the page we’re interested in...

# FOR OFFLINE DEVELOPMENT
# BASE_URL = "/Users/casey/Dropbox/GoogleScraper/Pages/"
BASE_URL = "http://www.google.com/search?q="
