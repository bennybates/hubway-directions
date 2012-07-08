require 'net/http'

class GoogleDistances
  
  def initialize(location_1, location_2, travel_mode)
    @base_url = "http://maps.googleapis.com/maps/api/distancematrix/xml?sensor=false&"
    @location_1 = location_1
    @location_2 = location_2
    options = "origins=#{transcribe(@location_1)}&destinations=#{(@location_2)}&mode=#{travel_mode}"
    directions_handle = open(URI.encode(@base_url + options))
  puts @base_url + options
    @xml = Hash.from_xml(directions_handle)
    @distances = @xml[ 'DistanceMatrixResponse' ]
    @status = find_status
  end

  def find_status
    @distances[ 'status' ]
  end

  def is_valid
    @status == 'OK'
  end

  def start_station
    @distances["row"][0]["element"]
  end

  def end_station
    @distances["row"][1]["element"]
  end

  def address
    @distances["destination_address"]
  end

  def xml
    unless @xml.nil?
       @xml
    else
      @xml ||= get_url(@xml_call)
    end
  end

  def time
    @distances["row"]["element"]["duration"]["value"].to_i/60
  end

  def xml_call
    @xml_call
  end

  def drive_time_in_minutes
    if @status != "OK"
      drive_time = 0
    else
      drive_time = doc.css("duration value").last.text
      convert_to_minutes(drive_time)
    end
  end

  def distance_in_miles
    if @status != "OK"
      distance_in_miles = 0
    else
      meters = doc.css("distance value").last.text
      distance_in_miles = (meters.to_f / 1610.22).round
      distance_in_miles
    end
  end
  
  def status
    @status
  end
    
  private
  
    def convert_to_minutes(text)
      (text.to_i / 60).ceil
    end
  
    def transcribe(location)
      location.gsub(" ", "+")
    end

    def get_url(url)
      Net::HTTP.get(::URI.parse(url))
    end
  
end
