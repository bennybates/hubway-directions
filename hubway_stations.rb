require 'open-uri'
file_handle = open("http://www.thehubway.com/data/stations/bikeStations.xml")
hash = Hash.from_xml{file_handle)
hash["stations"]["station"][18]["id"]

