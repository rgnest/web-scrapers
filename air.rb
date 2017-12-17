require 'nokogiri'
require 'selenium-webdriver'
require 'rspec/expectations'
require 'pp'
require 'rubygems'
require 'mysql2'

#caps = Selenium::WebDriver::Remote::Capabilities.chrome("desiredCapabilities" => {"takesScreenshot" => true}, "chromeOptions" => {"binary" => "/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary"})



#con = Mysql.new 'localhost', 'root', 'yfhbtkm', 'devel'

#DataMapper.setup(:default,
#  :adapter => 'mysql',
#  :host => 'localhost',
#  :username => 'root',
#  :password => 'yfhbtkm',
#  :database => 'devel',
#  :encoding => 'UTF-8'
#)

  
@browser = Selenium::WebDriver.for :chrome
@browser.get("https://www.airbnb.com/s/tel-aviv/homes?allow_override%5B%5D=&s_tag=0rC5BKx4")



begin               
 # Some exception throwing code
rescue => e
  puts "Error during processing: #{$!}"
  puts "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
end


#Get main page
@browser.get("https://www.airbnb.com/s/tel-aviv/homes?allow_override%5B%5D=&s_tag=0rC5BKx4")

@maxpage = 0
@data = Array.new
@i = 0

#Get paging all links, and take last as maximum page
@pages = @browser.find_elements(:class, "numberContainer_1bdke5s")

puts "pages ==== "
pp @pages 

	@pages.each { |x|
		@maxpage = x.text		
	}
	
	@pages=""

puts "Total pages " + @maxpage.to_s + "\n"

	(1..@maxpage.to_i).each { |z|

		@i = @i + 1
		@links = nil

		puts "\n===Main page number #{@i}\n"		
		@browser.get("https://www.airbnb.com/s/Tel-Aviv-Yafo--Israel/homes?allow_override%5B%5D=&s_tag=T7yMmlYE&section_offset=1")
		
			@links =  @browser.find_elements(:class, "anchor_surdeb")
			puts "\nGet total " + @links.count.to_s + " description pages links"

			@links2 = Array.new
			#@links2.clear
			#@links = Array.new

			#Ну че делать надо...
			@links.each { |link|
				@links2.push(link.attribute("href").to_s)
			}

			#puts "Link 2 " + @links2.count.to_s

			@f = 0

				@links2.each { |link|
					
					@f = @f + 1
					
					@link = link
					#Go to description page
					#puts "Go to description page #{@link}"
					
					puts  "=== Open description link # #{@f}: " + link
					
					@browser.get(@link)
 					
 					@title =  @browser.find_element(:css, "div#listing_name").text
 					
 					#Ибо не понятно почему но иногда элемент не ловится
 					begin
 					@price =  @browser.find_element(:css, "span.text_5mbkop-o_O-size_large_16mhv7y-o_O-weight_bold_153t78d-o_O-color_inverse_1lslapz-o_O-inline_g86r3e span").text
 					rescue
 					end
 					
 					#Ну текста просто тупо может не быть
 					begin
 					@body = @browser.find_elements(:class, "simple-format-container")
 					rescue
 					end
 
 					@body.each { |text| text.text }
 					#@body = @b
 
 					@data.push({ 'header' => @title, 'price' => @price, 'body' => @body, 'link' => link })
					
				}
}

client = Mysql2::Client.new(:host => "localhost", :username => "root")
	
@data.sort_by { |hsh| hsh[:price] }
					
fh = File.new("air.js", "w+")
fh.puts @data.to_json
fh.close	
	
#@browser.quit
#@headless.destroy	   


