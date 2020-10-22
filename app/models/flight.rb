class Flight < ActiveRecord::Base
    has_many :tickets
    has_many :passengers, through: :tickets

    # Checks whether a searched flight already exists in the DB
    def self.find_matching_flight(searchedflight)
        self.find_by({
            origin: searchedflight.origin,
            destination: searchedflight.destination,
            departure: searchedflight.departure,
            carrier_id: searchedflight.carrier_id,
            price: searchedflight.price
        })
    end

    # Create a new Flight instance and save in flights table if it doesn't already exist in the table.
    def self.create_from_searchedflight(searchedflight)
        origin = searchedflight.origin
        destination = searchedflight.destination
        departure = searchedflight.departure
        carrier_id = searchedflight.carrier_id
        price = searchedflight.price

        new_flight = self.create({
            origin: origin, 
            destination: destination, 
            departure: departure, 
            carrier_id: carrier_id,
            price: price
        })

        new_flight
    end

end