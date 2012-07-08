require 'open-uri'
require File.join(File.dirname(__FILE__), './lib/google_directions')
require File.join(File.dirname(__FILE__), './lib/google_distances')
  
    RAD_PER_DEG = 0.017453293  #  PI/180
  
 # the great circle distance d will be in whatever units R is in
  
    Rmiles = 3956           # radius of the great circle in miles
    Rkm = 6371              # radius in kilometers...some algorithms use 6367
    Rfeet = Rmiles * 5282   # radius in feet
    Rmeters = Rkm * 1000    # radius in meters

GOOGLE_MAPS_API_KEY = 'AIzaSyBWlmCvSVbaQlsXiqNIGk2kElldZ5wz6tw'
# THIS WORKS
# http://maps.google.com/maps/api/directions/xml?sensor=false&origin=42.344023,-71.057054&destination=1404%20Commonwealth%20Ave,%20Brighton,%20MA&mode=walking

def haversine_distance( lat1, lon1, lat2, lon2 )


    dlon = lon2 - lon1
    dlat = lat2 - lat1
  
    dlon_rad = dlon * RAD_PER_DEG
    dlat_rad = dlat * RAD_PER_DEG
     
    lat1_rad = lat1 * RAD_PER_DEG
    lon1_rad = lon1 * RAD_PER_DEG
  
    lat2_rad = lat2 * RAD_PER_DEG
    lon2_rad = lon2 * RAD_PER_DEG
  
    puts "#{lat1},#{lon1} : #{lat2},#{lon2}"
    puts "dlon: #{dlon}, dlon_rad: #{dlon_rad}, dlat: #{dlat}, dlat_rad: #{dlat_rad}"
  
    a = (Math.sin(dlat_rad/2))**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * (Math.sin(dlon_rad/2))**2
    c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))
    puts "#{a}"  
    puts "#{c}"

    dFeet = Rfeet * c         # delta in feet

#    @distances["mi"] = dMi
#    @distances["km"] = dKm
#    @distances["ft"] = dFeet
#    @distances["m"] = dMeters
end

  start_loc = 'bleep blarg'
  start_loc = '1404 Commonwealth Ave Brighton MA'
  end_loc = '22 Thomson Pl Boston MA'
  travel_mode = 'walking'
  origin_address = GoogleDirections.new(start_loc, 'Boston MA', travel_mode)
  destination_address = GoogleDirections.new(end_loc, 'Boston MA', travel_mode)  
  
  if origin_address.is_valid && destination_address.is_valid 

    shortest_to_start = -1
    shortest_to_end = -1
    all_destinations = ""
    start_lat = ''
    start_long = ''
    end_lat = ''
    end_long = ''

    hubway_handle = open("http://www.thehubway.com/data/stations/bikeStations.xml")
    stations = Hash.from_xml(hubway_handle)
    stations[ 'stations' ][ 'station' ].each do | this |
      if this[ 'nbBikes' ].to_i > 0 && this[ 'locked' ] == 'false'
        station_lat = this[ 'lat' ].to_f
        station_long = this[ 'long' ].to_f
        origin_lat = origin_address.start_latitude.to_f
        origin_long = origin_address.start_longitude.to_f
        dest_lat = destination_address.start_latitude.to_f
        dest_long = destination_address.start_longitude.to_f
        dist_to_start = haversine_distance( origin_lat, origin_long, station_lat, station_long )
        dist_to_dest = haversine_distance( dest_lat, dest_long, station_lat, station_long )
        
        if shortest_to_start == -1
            puts "here"
            shortest_to_start = dist_to_start
            start_lat = station_lat
            start_long = station_long
            shortest_to_end = dist_to_dest
            end_lat = station_lat
            end_long = station_long
            puts "#{dist_to_start}, #{shortest_to_start}"
        else
            if dist_to_start < shortest_to_start
                shortest_to_start = dist_to_start
                start_lat = station_lat
                start_long = station_long
            end
            if dist_to_dest < shortest_to_end
                shortest_to_end = dist_to_dest
                end_lat = station_lat
                end_long = station_long
            end
        end
      end
    end


    start_id = '258+Brighton+Ave,+Boston,+MA+02134,+USA'
    end_id = '700+Atlantic+Ave,+Boston,+MA+02205,+USA'
    start_station = "#{start_lat},#{start_long}"
    end_station = "#{end_lat},#{end_long}"


    to_bike = GoogleDirections.new(start_loc, start_station, "walking")
    bike_route = GoogleDirections.new(start_station, end_station, "bicycling")
    from_bike = GoogleDirections.new(end_station, end_loc, "walking")
   
    puts ""
    puts to_bike.time.to_s + ' minute walk from '
    puts to_bike.start_address + ' to ' + to_bike.end_address
    puts bike_route.time.to_s + ' minute bike ride from'
    puts bike_route.start_address + ' to ' + bike_route.end_address
    puts from_bike.time.to_s + ' minute walk to ' 
    puts from_bike.start_address + ' from ' + from_bike.end_address

    map = 'http://maps.googleapis.com/maps/api/staticmap?size=640x640&path=enc:' + 
    to_bike.path + '&path=enc:' + bike_route.path + '&path=enc:' + from_bike.path +
    '&key=' + GOOGLE_MAPS_API_KEY + '&sensor=false' + '&markers=' + to_bike.start_address +
    '|' + bike_route.start_address + '|' + bike_route.end_address + '|' +
    from_bike.end_address
    puts map
  end


