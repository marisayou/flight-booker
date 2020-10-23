require 'uri'
require 'net/http'
require 'openssl'
require 'json'
require_relative '../config/environment'

# Access data from Skyscanner API
def access_api(url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    file = File.open('bin/key.rb')
    request = Net::HTTP::Get.new(url)
    request["x-rapidapi-host"] = 'skyscanner-skyscanner-flight-search-v1.p.rapidapi.com'
    request["x-rapidapi-key"] = file.read

    response = http.request(request).read_body
    response_hash = JSON.parse(response)    
end

# Places in the Skyscanner API have codes (ex. Seattle is SEA-sky), so this method gets the code of an input location
def get_place(query)
    url = URI("https://rapidapi.p.rapidapi.com/apiservices/autosuggest/v1.0/US/USD/en-US/?query=#{query}")

    response_hash = access_api(url)
    if response_hash == nil || response_hash["Places"] == nil || response_hash["Places"][0] == nil
        return nil
    end
    response_hash["Places"][0]["PlaceId"]
end

# Gets flight infor from the API given an origin, destination, and departure date
def get_api(origin, destination, departure)
    origin = get_place(origin)
    destination = get_place(destination)
    if origin == nil || destination == nil
        return nil
    end
    url = URI("https://rapidapi.p.rapidapi.com/apiservices/browseroutes/v1.0/US/USD/en-US/#{origin}/#{destination}/#{departure}?inboundpartialdate=anytime")

    response_hash = access_api(url)
end 

# This method is called when an user searches for flights. It returns a list of available flights that matches the user's search requirements
def get_flight_info(origin, destination, departure)
    results = []

    origin = origin
    destination = destination
    info_hash = get_api(origin, destination, departure)
    if info_hash == nil || info_hash["Quotes"] == nil
        return nil
    end

    flights = info_hash["Quotes"].select {|f|
        f["OutboundLeg"]["DepartureDate"].to_date == departure.to_date
    }
    
    flights.each {|f|
        flight = SearchedFlight.new(origin, destination, f["OutboundLeg"]["DepartureDate"], f["OutboundLeg"]["CarrierIds"][0], f["MinPrice"])
        results << flight
    }
    
    results
end
