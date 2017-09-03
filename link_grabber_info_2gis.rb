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
require 'phonie'

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
  #storage_names[:default] = "struct_5217_companies"
  property :id, Serial
  property :city, Integer
  property :header, Text, :length => 500
  property :url, Text, :length => 500
  property :email, Text, :length => 500
  property :address, Text, :length => 500
  property :phone, Text, :length => 500
  property :otrasl, Text, :length => 500
  property :techurl, Text, :length => 500
  default_scope(:default).update(:order => [:id.desc])
end

Emails = Hash.new

(1..Companies.count).each { |current|

 company = Companies.get(current)

if company.nil?
next
end

    #@comp.each { |company| 
  
          #И непосредственно ссылку на эту компанию
          #href = v["href"]
          href = company.techurl
          
          puts "/****************************************************"
          puts "Компания #{company.header}"
          puts "Ссылка #{company.url}"
          
          #И вот мы полезли непосредственно за компанией
          techurl = href
          begin
          #puts "\t\t\tЗапрос https://2gis.ru#{href}"
          page3 = Nokogiri::HTML(open("https://2gis.ru#{href}"), nil, 'UTF-8')
          rescue
          puts "\t!!! ссылка на компанию мертвая https://2gis.ru#{href}"
          next
          end
          
          
          #Название из двух частей, клеим
          header = page3.css("h1.cardHeader__headerNameText")
          header2 = page3.css("h1.cardHeader__headerDescriptionText")
          
          header = header.children
          header2 = header2.children
          header = "#{header} #{header2}"
          
          #Адрес
          address = page3.css("span.card__addressPart")
          address =  address.css("a")[0]
          if address.to_s.length>0
          address = address.children
          else
          address = nil
          end
        
          
          #Телефон
          phone = page3.css("span.contact__phonesItemLinkNumber")
          phone =  phone.css("span")
          phone = phone.children.to_s
          
          #Сайт
          site = company.url
          
          #Список ссылок, для сборки финальной отрасли
          rub = page3.css("div.cardRubrics__rubrics")

          string = Array.new
            
          rub.each { |r|
            r.css("a").each { |r2|
              string.push(r2.children.to_s)
            }
          }
          
          otrasl = string.join(" ")

#puts header
#exit
          #header = header.encode(Encoding.find('UTF-8'), encoding_options)
    
          src = ""
            
          begin
          puts "\t\t\tЗапрос к сайту компании [http://#{site}]"
          src = open("http://#{site}", &:read)
          #src = src.encode(Encoding.find('UTF-8'), encoding_options)
          rescue Exception => e
          puts e.message  
            puts "\t\t\t404 основной сайт #{site}"
          end

          @Emails = Hash.new
          @a = Array.new
          
          if src
            #begin
              a = src.to_s.scan(/([a-z0-9_\.-]+@[a-z0-9_\.-]+\.[a-z\.]{2,6})/)
            #rescue
            #end
          end
    
          if @a.length>0
            puts "\t\t\tОбнаружен e-mail"
          end

          /([a-z0-9_\.-]+@[a-z0-9_\.-]+\.[a-z\.]{2,6})/.match(src.to_s)
        
          #pp Regexp.last_match(0)
        
          if !Regexp.last_match(0).nil?
            puts "\t\t\tЭкстра email #{site}"
            Emails[Regexp.last_match(0)] = 1
          end
    
          src1 = ""
    
          begin
				  src1 = open("http://#{site}/contacts", &:read)
          #src1 = src1.encode(Encoding.find('UTF-8'), encoding_options)
          #src1 = src1.to_s            
          rescue
            puts "\t\t\t404 #{site}/contacts"
          end
    
          if src1
            #begin
              b = src1.to_s.scan(/([a-z0-9_\.-]+\@[a-z0-9_\.-]+\.[a-z\.]{2,6})/)              
            #rescue
            #end
          end
          
          /([a-z0-9_\.-]+\@[a-z0-9_\.-]+\.[a-z\.]{2,6})/.match(src1.to_s)
        
          if !Regexp.last_match(0).nil?
            puts "\t\t\tЭкстра email #{site}/contacts"
            Emails[Regexp.last_match(0)] = 1
          end
          
          if a.length >0
          a.map{ |u| Emails[u] = 1 }
          end
          if b.length >0
          b.map{ |u| Emails[u] = 1 }
          end
          email = Emails.keys.join(",")
                  Emails.clear
                  if a.class == "Array"
                  a.clear
                  end
                  if b.class == "Array"
                  b.clear
                  end          
                  
          if email =~ /([a-z0-9_\.-]+)\@([a-z0-9_\.-]+)\.([a-z\.]{2,6})/
           pp email 
          #1 zoo  = Zoo.get(1)
          tmpcmp = Companies.get(company.id)
            
          #comp = Companies.new
          tmpcmp.header = header.to_s
          tmpcmp.address = address.to_s
          tmpcmp.phone = phone
          tmpcmp.url = company.url
          #comp.techurl = techurl
          tmpcmp.otrasl = otrasl
          tmpcmp.email = email
         
          begin
          tmpcmp.save
          puts "\t\t\tКомпания [#{header}] записана, так как имеет \n\t\t\tэлектронный адрес [#{email}]"
          
          email = ""
          otrasl = ""
          techurl = ""
          site = ""
          phone = ""
          header = ""
          address = ""
          
          #saved = saved+1
          rescue Exception => e
						
          puts e.message  
          puts e.backtrace.inspect
          
          comp.errors.each { |p|
            puts p
            puts "#/*******************************************************************************/"
            pp comp
            puts "#/*******************************************************************************/"
          } 
          
          end
          else  
            puts "Компания #{header} удалена из базы, нет E-mail"
            company.destroy
          end
    #}
  }