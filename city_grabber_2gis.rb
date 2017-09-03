#!/usr/bin/ruby

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

#encoding: utf-8
require 'nokogiri'
require 'open-uri'
require 'uri'
require 'pp'
require 'mysql'


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

class Cities
  include DataMapper::Resource
  property :id, Serial
  property :header, String
  property :url, String
  default_scope(:default).update(:order => [:id.desc])
end

con = Mysql.new 'localhost', 'root', 'yfhbtkm', 'devel'

@src = open("https://2gis.ru/countries/global/abakan?queryState=center%2F81.071378%2C53.720644%2Fzoom%2F5", &:read)
@data = Nokogiri::HTML(@src.to_s)

list = @data.css(".world__section:nth-child(1) li.world__listItem a")

@city = Cities.new

list.each { |c|

@url = c["href"].to_s.force_encoding("UTF-8")
@header = c.text.to_s.force_encoding("UTF-8")

@city.url = @url
@city.header = @header
pp @city

 sth = con.prepare "Insert into cities(header, url) value(?,?)"
 sth.execute @header, @url



#begin
#@city.save
#rescue Exception => e
#puts "\t\t\t !!! #{e.message}"
#end

}