require 'rubygems'
require 'nokogiri'
require 'mechanize'
require 'open-uri'
require 'pry'

class Pages 
  attr_reader :animal_type, :search_type
  def initialize(animal_type, search_type)
    @animal_type = animal_type
    @search_type = search_type
  end
  def has_result?
    url = "http://adoptapet.com.au/search/searchResults.asp?animalType=" + @animal_type + "&searchType=" + @search_type + ""
    doc = Nokogiri::HTML(open(url))
    string = doc.at_css('legend').to_s
    if string.include? "No Animals Found"
      puts "No Animals Found"
      return nil
    else
      return url
    end
  end
end

class Pets
  attr_accessor :detail_url
  def initialize(detail_url)
    @detail_url = detail_url
  end
  def get_info
    agent = Mechanize.new
    page = agent.get(@detail_url)
    #Access to the details page of a single pet
    detail_url = page.link_with(:dom_class => "view_details").click
    doc = Nokogiri::HTML(open(detail_url.uri.to_s))
    details = Array.new
    doc.css('.animal_details_table').each do |detail_table|
      detail_table.css('td.label').each do |item|
        details << item.next_element.text
      end
    end
    details << doc.at_css('#petDefaultPic').xpath('@src').text
    details << doc.at_css('.page_content').text
    puts details.inspect
  end
end

Page1 = Pages.new("94", "4")
url = Page1.has_result?
Pets1 = Pets.new(url)
Pets1.get_info

