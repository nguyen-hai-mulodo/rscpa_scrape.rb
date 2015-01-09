require "rubygems"
require "nokogiri"
require "mechanize"
require "open-uri"

#This scraper will try to get all pets and their information at http://www.rspca.org.au/ by selection of animal_type

URL_PREFIX = "http://adoptapet.com.au/search/searchResults.asp?"

class Result_Pages
  
  attr_reader :animal_type

  def initialize(animal_type)
    @animal_type = animal_type
    @result_url = "#{URL_PREFIX}animalType=#{@animal_type}&searchType=4"
    @result_page = Nokogiri::HTML(open(@result_url))
  end

  def has_animal?
    string_to_check = @result_page.at_css('legend').to_s
    if string_to_check.include?("No Animals Found")
      false
    else
      true
    end
  end
  
  def result_table
    result_table = @result_page.css(".search-results-table")
    return result_table
  end

end

class Detail_Page

  attr_reader :animal_id

  def inittialize(animal_id)
    @animal_id = animal_id
  end

  def info
    detail_url = "#{URL_PREFIX}animalID=#{@animal_id}&seachType=4"
    detail_page = Nokogiri::HTML(open(detail_url))
    details = Array.new
    detail_page.css('.animal_details_table').each do |detail_table|
      detail_table.css('td.label').each do |item|
        details << item.next_element.text
      end
    end    

    profile_picture = doc.at_css('#animal_gallery')
    if profile_picture.include?("petDefaultPic")
      details << profile_picture.at_css('#petDefaultPic')['src']
    else
      details << profile_picture.at_css('#nophoto')['src']
    end

    details << doc.at_css('.page_content').text

    return details
  end
end

Test = Result_Pages.new("2")
Test_Detail = Detail_Page.new
if Test.has_animal?
  doc = Test.result_table
  doc.css(".view_details").each do |item|
    link = item.attr('href').split("animalid=")
    id = link[1]
  end
end
