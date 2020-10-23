class Ticket < ActiveRecord::Base
    belongs_to :passenger
    belongs_to :flight

    # Returns a string with info about an instance of a ticket
    def info
        "Passenger: #{self.passenger.name}\n  Origin: #{self.flight.origin}\n  Destination: #{self.flight.destination}\n  Departure Date: #{self.flight.departure}\n  Price: $#{'%.2f' % self.flight.price}\n\n"
    end

    def self.check_duplicate_book(passenger, searched_flight)
        flight = Flight.find_matching_flight(searched_flight)
        if flight == nil
            return true
        end
        return self.find_by({
            passenger: passenger,
            flight: flight
        }) == nil
    end
end