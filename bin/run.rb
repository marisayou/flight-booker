require_relative '../config/environment'

def welcome
    while true
        loggedin = false
        passenger = nil

        while !loggedin
            # Show this option menu while no user is logged in. 
            # After a new user signs up, he/she will return to this menu before logging in.
            puts "Welcome to Flight Booker. Select the action you want to take."
            puts "  1. Login"
            puts "  2. Sign up"
            puts "  3. Exit"
            answer = gets.strip
            if answer == "1"
                passenger = Passenger.login
                #binding.pry
                if passenger == nil
                    puts "\nLogin failed."
                    next
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
            # Show this menu while user is logged in. Unless the user chooses to logout, 
            # he/she will return to this menu after completing any of the other options
            puts "Hello #{passenger.name}. Why are you here?"
            puts "  1. View/Add Balance"
            puts "  2. Find and Book flights"
            puts "  3. View My Tickets"
            puts "  4. Logout"

            answer = gets.strip
            if answer == "1"
                puts "Your current balance is $#{'%.2f' % passenger.balance}."
                puts "Do you want to add to your balance? (yes/no)"
                add_balance = gets.strip
                puts "\n"
                if add_balance == "yes"
                    puts "How much do you want to add to your balance?"
                    to_add = gets.to_i
                    passenger.add_money_to_account(to_add)
                    puts "Thank you. Your new balance is $#{'%.2f' % passenger.balance}.\n\n"
                    puts "Press ENTER to continue"
                    gets
                end
                    
            elsif answer == "2"
                puts "(Enter 'exit' to exit from flight search and booking)"
                puts "Where are you?"
                origin = gets.strip
                if origin == "exit"
                    puts "\n"
                    next
                end
                puts "Where do you wanna go?"
                destination = gets.strip
                if destination == "exit"
                    puts "\n"
                    next
                end
                puts "Which year do you wanna go?"
                year = gets.strip
                if year == "exit"
                    puts "\n"
                    next
                end
                puts "Which month?"
                month = gets.strip
                if month == "exit"
                    puts "\n"
                    next
                end
                if month.size == 1
                    month = "0" + month
                end
                puts "Which date?"
                date = gets.strip
                if date == "exit"
                    puts "\n"
                    next
                end
                if date.size == 1
                    date = "0" + date
                end

                departure = "#{year}-#{month}-#{date}".to_date
                searched_flights = SearchedFlight.find_and_print_flight(origin, destination, departure)

                # Goes back to main logged-in menu if no flights match the user's search
                if searched_flights == nil || searched_flights.length == 0
                    puts "Sorry! No flights match your search.\n\n"
                    next
                end

                puts "Which one do you want?"
                chosen_searched_flight = nil
                flight_index = nil
                # Continue asking user to choose a flight until his/her choice is a valid flight
                while true 
                    flight_index = gets.strip
                    if flight_index == "exit"
                        break
                    end
                    flight_index = flight_index.to_i - 1  
                    while flight_index >= searched_flights.length || flight_index < 0
                        puts "That doesn't seem like a valid number. Try again."
                        flight_index = gets.strip.to_i - 1
                    end
                    
                    chosen_searched_flight = searched_flights[flight_index]


                    puts "Ok.... So you want to book this flight for $#{'%.2f' % chosen_searched_flight.price}. Is that right? (yes/no)"

                    confirm_flight = gets.strip
                    if confirm_flight == "yes"
                        break
                    end
                    puts "No? Then choose another flight"
                end
                
                if flight_index == "exit"
                    puts "\n"
                    next
                end

                if passenger.balance < chosen_searched_flight.price
                    puts "Insufficient balance. Purchase denied."
                    next
                end

                # If the user already bought this ticket, they can't rebuy it.
                if !Ticket.check_duplicate_book(passenger, chosen_searched_flight)
                    puts "You already bought this ticket! No purchase has been made.\n"
                    next
                end

                # If there is a flight in the flights table that matches the flight the user chose (including price), then choose that flight from the DB.
                # Otherwise, create a new Flight and save it in the table.
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
