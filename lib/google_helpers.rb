def is_not_valid( check_location )
	valid_destination = 'Boston MA'
	  @base_url = "http://maps.google.com/maps/api/directions/xml?&sensor=false&"
    options = "origin=#{transcribe(check_location)}&destination=#{transcribe(valid_destination)}&mode=#{travel_mode}"
    directions_handle = open(@base_url + options)
    @xml = Hash.from_xml(directions_handle)
    @directions = @xml[ 'DirectionsResponse' ]
    @directions[ 'status' ] != 'OK'
  end