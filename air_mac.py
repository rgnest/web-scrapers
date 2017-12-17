from pyvirtualdisplay import Display
from selenium import webdriver

d#isplay = Display(visible=0, size=(800, 600))
display.start()

from selenium import webdriver
from selenium.webdriver import ActionChains
from selenium.webdriver.common.keys import Keys

from selenium import webdriver  
from selenium.webdriver.common.keys import Keys  
from selenium.webdriver.chrome.options import Options

import os 
import sys
import re
from pprint import pprint
import json

PROXY = "localhost:8080"

browser = webdriver.Remote("http://google.com")
browser.get("https://www.airbnb.com/s/tel-aviv/homes?allow_override%5B%5D=&s_tag=0rC5BKx4")



pages = browser.find_elements_by_class_name("numberContainer_1bdke5s")

maxpage = 0

#/**********************
# [PAGE] Getting max pages
for i in pages:
	maxpage = i.text

print (maxpage)
exit

#print ("Total pages " + maxpage + "\n")

data = {}

for page in list(range(int(maxpage))):
	pagenumber = page
	page = "https://www.airbnb.com/s/Tel-Aviv-Yafo--Israel/homes?allow_override%5B%5D=&s_tag=u-1hYpQj&section_offset="+str(page)

	print("========================================================")
	print("Open page number "+str(pagenumber))
	print("Open page link: "+str(page))

	browser.get(page)
	#/**********************
	# [LINK] Getting each page links to description [flat] from picture
	links = browser.find_elements_by_class_name("anchor_surdeb")
	links = [link.get_attribute("href") for link in links]

	for link in links:
 		print("\n=== Open description link: " + link + "\n")
 		browser.get(link)
 		title = browser.find_element_by_css_selector("div#listing_name").text 	
 		price = browser.find_element_by_css_selector("span.text_5mbkop-o_O-size_large_16mhv7y-o_O-weight_bold_153t78d-o_O-color_inverse_1lslapz-o_O-inline_g86r3e span").text
 		
 		
 		#try:
 		body = browser.find_elements_by_css_selector("div.simple-format-container")
 			
 		text = ''
 			
 		for bd in body:
 			#print(str(bd.get_attribute('innerHTML')))
 			text = text + str(bd.get_attribute('innerHTML'))
 			text = str(text)
 			#print(text)

 		text = strip_tags(str(text))
 			
 		#except ValueError:
 		#	print("==! Empty body!")
 
 		Air.header = title
 		Air.price = ""
 		Air.body = ""
 		
 		connection = engine.connect() 
 		insert = Air.insert().values(header=title, price=price, body=str(body))
 		result = connection.execute(insert)

browser.close()