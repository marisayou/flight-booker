class Ticket < ActiveRecord::Base
    belongs_to :passenger
    belongs_to :flight



    def info
        "Passenger: #{self.passenger.name}\n  Origin: #{self.flight.origin.capitalize}\n  Destination: #{self.flight.destination.capitalize}\n  Departure Date: #{self.flight.departure}\n\n"

    end



end