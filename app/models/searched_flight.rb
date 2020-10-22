# This class is for flights that have been searched but have not been saved in the DB. 
# The DB stores flights that are booked by one or more passengers and are represented by the Flight class.
# SearchedFlight is a simple struct-like class for passing info from the API to the controller that deals with flight-booking logic.

require_relative '../../bin/api_info'

class SearchedFlight
    attr_reader :origin, :destination, :departure, :carrier_id, :price

    def initialize(origin, destination, departure, carrier_id, price)
        @origin = origin.split.map { |word| word.capitalize }.join(" ")
        @destination = destination.split.map { |word| word.capitalize }.join(" ")
        @departure = departure.to_date
        @carrier_id = carrier_id
        @price = price
    end

    # returns an array of flights whose origin, destination, and takeoff date match input parameters
    def self.find_and_print_flight(origin, destination, date)
        flights = get_flight_info(origin, destination, date)
        if flights == nil
            return nil
        end
        puts "Available flights: "
        flight_num = 1
        flights.each {|f|
            puts "#{flight_num}. Origin: #{f.origin}, Destination: #{f.destination}, Departure: #{f.departure}, Price: $#{'%.2f' % f.price}"
            flight_num += 1
        }
        puts "\n"
        flights
    end

end