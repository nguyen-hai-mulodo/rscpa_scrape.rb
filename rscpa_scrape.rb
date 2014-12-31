require 'rubygems'
require 'nokogiri'
require 'mechanize'
require 'open-uri'

class Pages 
  def initialize(animalType, searchType)
    @animalType = animalType
    @searchType = searchType
  end
  def has_result()
    url = "http://adoptapet.com.au/search/searchResults.asp?animalType=" + @animalType + "&searchType=" + @searchType + ""
    doc = Nokogiri::HTML(open(url))
    string = doc.at_css('legend').to_s
    if string.include? "No Animals Found"
      return false
    else
      return true
    end
  end
end
Page1 = Pages.new("94", "4")
puts Page1.has_result

# def findapet(type,state)
#   result_page = agent.get('http://adoptapet.com.au/search/searchResults.asp?animalType=#{type}&state=&searchtype=#{state}')
#   if result_page.search_result_name
# end
