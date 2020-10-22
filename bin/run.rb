require_relative '../config/environment'

def welcome
    while true
        loggedin = false
        passenger = nil
        while !loggedin
            puts "Welcome to Flight Booker. Select the action you want to take."
            puts "  1. Login"
            puts "  2. Sign up"
            puts "  3. Exit"
            answer = gets.strip
            if answer == "1"
                passenger = Passenger.login
                while passenger == nil
                    puts "Login failed. Try again"
                    passenger = Passenger.login
                    # TODO: make it end somehow
                end
                loggedin = true
            elsif answer == "2"
                Passenger.signup
            elsif answer == "3"
                puts "Goodbye."
                exit
            else
                puts "Unknown command. Try again."
            end
        end

        while loggedin
            puts "Hello #{passenger.name}. Why are you here?"
            puts "  1. View/Add Balance"
            puts "  2. Find and Book flights"
            puts "  3. View My Tickets"
            puts "  4. Logout"

            answer = gets.strip
            if answer == "1"
                puts "Your current balance is $#{'%.2f' % passenger.balance}."
                puts "How much do you want to add to your balance?"
                to_add = gets.to_i
                passenger.add_money_to_account(to_add)
                puts "Thank you. Your new balance is $#{'%.2f' % passenger.balance}.\n\n"
                puts "Press ENTER to continue"
                gets
            elsif answer == "2"
                puts "Where are you?"
                origin = gets.strip
                puts "Where do you wanna go?"
                destination = gets.strip
                puts "When? (YYYY-MM-DD)"
                departure = gets.strip.to_date
                flights = SearchedFlight.find_and_print_flight(origin, destination, departure)
                if flights == nil || flights.length == 0
                    puts "Sorry! No flights match your search.\n\n"
                    next
                end
                puts "Which one do you want?"
                chosen_searched_flight = nil
                while true 
                    flight_index = gets.strip.to_i - 1  # humans don't zero-index :)
                
                    # some err handling
                    while flight_index >= flights.length || flight_index < 0
                        puts "That doesn't seem like a valid number. Try again."
                        flight_index = gets.strip.to_i - 1
                    end
                    
                    chosen_searched_flight = flights[flight_index]
                    # book that flight for this person
                    puts "Ok.... So you want to book this flight for #{'%.2f' % chosen_searched_flight.price}. Is that right? (yes/no)"
                    confirm_flight = gets.strip
                    if confirm_flight == "yes"
                        break
                    end
                    puts "No? Then choose another flight"
                end
            
                if passenger.balance < chosen_searched_flight.price
                    puts "Insufficient balance. Purchase denied."
                    next
                end
                flight = Flight.find_matching_flight(chosen_searched_flight)
                if flight == nil
                    flight = Flight.create_from_searchedflight(chosen_searched_flight)
                end
                ticket = Ticket.create({passenger_id: passenger.id, flight_id: flight.id, price: chosen_searched_flight.price})
                passenger.deduct_money_from_account(chosen_searched_flight.price)
                puts "Congrats! You have booked a ticket from #{origin.capitalize} to #{destination.capitalize} for #{departure}!\n\n"
                puts "Press ENTER to continue"
                gets
            elsif answer == "3"
                passenger.get_info_from_tickets
            elsif answer == "4"
                puts "Ok. Bye!\n\n"
                loggedin = false
            else
                puts "Unknown command. Try again."
            end
        end
    end
end
    

welcome