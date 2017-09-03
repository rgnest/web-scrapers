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
  :database => 'develop',
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


page = Nokogiri::HTML(open("http://www.mirstroek.ru/companies/"), nil, 'UTF-8')

page = page.encode(Encoding.find('UTF-8'), encoding_options)

table = page.css("table.category_list")
elements = table.css("td.pad-top1")

puts elements
