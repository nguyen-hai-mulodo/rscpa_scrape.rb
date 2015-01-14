require "rubygems"
require "nokogiri"
require "mechanize"
require "open-uri"
require 'ostruct'
require "json"

#This scraper will try to get all pets and their information at http://www.rspca.org.au/ by selection of animal_type

SEARCH_URL_PREFIX = "http://adoptapet.com.au/search/searchResults.asp?%s&searchType=4"
DETAIL_URL_PREFIX = "http://adoptapet.com.au/animal/animaldetails.asp?searchtype=4&%s"
class PetSearch
  
  attr_reader :animal_type

  def initialize(animal_type)
    @animal_type = animal_type
  end

  def result_url
    @result_url = "#{SEARCH_URL_PREFIX}" % ["animalType=#{animal_type}"]
  end

  def result_page
    @result_page = Nokogiri::HTML(open("#{result_url}"))
  end

  def has_animal?
    string_to_check = @result_page.at_css('legend').to_s
    !string_to_check.include?("No Animals Found")
  end
  
  def result_table
    result_table = @result_page.css(".search-results-table")
  end

end

class PetImporter

  attr_accessor :animal_id

  def initialize(animal_id)
    @animal_id = animal_id
  end

  def detail_url
    @detail_url = "#{DETAIL_URL_PREFIX}" % ["animalid=#{animal_id}"]
  end

  def detail_page
    @detail_page = Nokogiri::HTML(open(detail_url))
  end

  def profile_picture
    @profile_picture = detail_page.at_css('#animal_gallery')
  end

  def info
    details = Array.new
    detail_page.css('.animal_details_table').each do |detail_table|
      detail_table.css('td.label').each do |item|
        details << item.next_element.text
      end
    end    

    if profile_picture.to_s.include?("petDefaultPic")
      details << profile_picture.at_css('#petDefaultPic')['src']
    else
      details << profile_picture.at_css('#nophoto')['src']
    end

    details << detail_page.at_css('.page_content').text

    @pet = OpenStruct.new
    @pet.name = details[0]
    @pet.type = details[1]
    @pet.breed = details[2]
    @pet.sex = details[3]
    @pet.size = details[4]
    @pet.colour = details[5]
    @pet.age = details[6]
    @pet.id = details[7]
    @pet.location = details[8]
    @pet.phone = details[9]
    @pet.address = details[10]
    @pet.photo_url = details[11]
    @pet.description = details[12]
  end

  def import
    File.open("temp.json","w") do |f|
      f.write(@pet.to_json)
    end
  end

end

Test = PetSearch.new("2")

Test.result_url
Test.result_page
Test.has_animal?


Jess = PetImporter.new("375244")

Jess.detail_url
Jess.detail_page
Jess.profile_picture
Jess.info
Jess.import


