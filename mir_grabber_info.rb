#!/usr/bin/ruby

#encoding: utf-8

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'digest'
require 'pp'
require 'json'
require 'uri'
require 'open-uri'
require 'uri'

require 'data_mapper'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'

require 'dm-core'
require 'dm-validations'
#
DataMapper.setup(:default,
  :adapter => 'mysql',
  :host => 'localhost', 
  :username => 'root',
  :password => 'yfhbtkm',
  :database => 'devel',
  :encoding => 'UTF-8'
)

class Companies
  include DataMapper::Resource
  property :id, Serial
  property :city, Text
  property :header, Text, :length => 500, :required => true, :lazy => false
  property :url, Text, :length => 500, :required => true, :lazy => false
  property :email, Text, :length => 500, :required => true, :lazy => false
  property :address, Text, :length => 500
  property :phone, Text, :length => 500
  property :otrasl, Text, :length => 500
  property :techurl, Text, :length => 500
  default_scope(:default).update(:order => [:id.desc])
end

@counter = 0
@company = Companies.new()
@total = Companies.count

(0..Companies.count).each { |current|
	#get current company
	@company = Companies.get(current)

	
	if @company.nil?
		next
	end
	
 puts @company.city

		  @header = @company.header

      #    if @company.email.length>0
	    #      @counter = @counter+1
	    #      puts " #{current} Компания имеет email, #{[@company.email]} пропущена."
	    #      puts "****************************************************"
			#  next
		  #end
          
          #Сайт
          @site = @company.url
          
		  if @site.length<1
			  next
		  end
          
          #puts current
          
          if @site =~ /a href/
          
          @url = Nokogiri::HTML(@site.to_s)
          
		  @url = @url.children.children.children.children.text
		  @site = @url
          end
          
          puts "****************************************************"
          puts "[[[ Пропущено компаний #{@counter} ]]]"
          puts "Компания #{@header}"
          puts "Ссылка #{@site}"

		  #Сбрасываем счетчик пропущенных компаний
          @counter = 0
          
          @src = String.new
            
          begin
          puts "\t\t\tЗапрос к сайту компании [#{@site}]"
          @src = open(@site, &:read)
          rescue
            puts "\t\t\t404 #{@site}"
			#next
          end
          
          @src = @src.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')

          @Emails = Hash.new
          @a = Array.new
          
          if @src
            #begin
              @a = @src.to_s.scan(/([a-z0-9_\.-]+@[a-z0-9_\.-]+\.[a-z\.]{2,6})/)
            #rescue
            #end
          end
 
		  if @a.length>0
			  puts "\t\t\tОбнаружен e-mail"
		  end
    
          /([a-z0-9_\.-]+@[a-z0-9_\.-]+\.[a-z\.]{2,6})/.match(@src.to_s)        
        
          if !Regexp.last_match(0).nil?
            puts "\t\t\tЭкстра email 1 #{@site}"
            @Emails.store(Regexp.last_match(0).to_s, "111")
          end
    
		  @src1 = String.new
		  @b = Array.new
		      
          begin
				  @src1 = open("http://#{@site}/contacts", &:read)
          rescue
            puts "\t\t\t404 #{@site}/contacts"
          end
    
          if @src1
            begin
              @b = @src1.to_s.encode("UTF-8").scan(/([a-z0-9_\.-]+\@[a-z0-9_\.-]+\.[a-z\.]{2,6})/)              
            rescue
            end
          end
          
          if @b.length>0
			  puts "\t\t\tОбнаружен e-mail 2"
		  end
          
      #@src1 = @src1.to_s.encode("UTF-8")

      begin
		  /([a-z0-9_\.-]+@[a-z0-9_\.-]+\.[a-z\.]{2,6})/.match(@src1.to_s)
      rescue
      end
        
          if !Regexp.last_match(0).nil?
            puts "\t\t\tЭкстра email 2 #{@site}/contacts"
			@Emails.store(Regexp.last_match(0).to_s, "222")
          end
                    
          if @a.length >0
	      
	      if @a.length >0
          @a.map{ |u| @Emails[u.pop] = 2 }
          end
          end
          if @b.length >0
          @b.map{ |u| @Emails[u.pop] = 2 }
          end
		  
          @email = String.new
          
          @email = @Emails.keys.join(",")

                  @Emails.clear
                  if @a.class == "Array"
                  @a.clear
                  end
                  if @b.class == "Array"
                  @b.clear
                  end          

          tmpcmp = Companies.new
          tmpcmp = Companies.get(@company.id)
                  
          if @email.length>0
	          
          tmpcmp.email = @email
         
	         puts "SAVE\nКомпания [#{@header}] записана,\nтак как имеет \nэлектронный адрес [@#{@email}]"
	      
	      tmpcmp.save
	     else
		     puts "DELETE\nEmail не обнаружен.\nКомпания [#{@header}] удалена из базы."
		  tmpcmp.destroy
		 end
}



    