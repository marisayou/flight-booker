require 'uri'
require 'net/http'
require 'openssl'
require 'json'
require_relative '../config/environment'

# Quotes

def access_api(url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["x-rapidapi-host"] = 'skyscanner-skyscanner-flight-search-v1.p.rapidapi.com'
    request["x-rapidapi-key"] = ''  # change this with the api key before running.

    response = http.request(request).read_body
    response_hash = JSON.parse(response)    
end

def get_place(query)
    url = URI("https://rapidapi.p.rapidapi.com/apiservices/autosuggest/v1.0/US/USD/en-US/?query=#{query}")

    response_hash = access_api(url)
    response_hash["Places"][0]["PlaceId"]
end

def get_api(origin, destination, date)
    origin = get_place(origin)
    destination = get_place(destination)
    url = URI("https://rapidapi.p.rapidapi.com/apiservices/browseroutes/v1.0/US/USD/en-US/#{origin}/#{destination}/#{date}?inboundpartialdate=anytime")

    response_hash = access_api(url)
end 

def get_flight_info(origin, destination, departure)
    results = []

    origin = origin.downcase
    destination = destination.downcase
    info_hash = get_api(origin, destination, departure)
    flights = info_hash["Quotes"].select {|f|
        f["OutboundLeg"]["DepartureDate"].to_date == departure.to_date
    }
    
    flights.each {|f|
        flight = SearchedFlight.new(origin, destination, f["OutboundLeg"]["DepartureDate"], f["OutboundLeg"]["CarrierIds"][0], f["MinPrice"])
        results << flight
    }
    
    results
end

# generates a uniquely identifiable ID for each of the flight that are queried 
# by appending the flight carrier ID, origin ID, destination ID, and the departure date.
# def generate_id(flight)
#     outboundleg = flight["OutboundLeg"]
#     return outboundleg["CarrierIds"][0].to_s + outboundleg["OriginId"].to_s + outboundleg["DestinationId"].to_s + outboundleg["DepartureDate"]
# end