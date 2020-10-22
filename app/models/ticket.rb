class Ticket < ActiveRecord::Base
    belongs_to :passenger
    belongs_to :flight

    # Returns a string with info about an instance of a ticket
    def info
        "Passenger: #{self.passenger.name}\n  Origin: #{self.flight.origin}\n  Destination: #{self.flight.destination}\n  Departure Date: #{self.flight.departure}\n  Price: $#{'%.2f' % self.flight.price}\n\n"
    end

end