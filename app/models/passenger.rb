class Passenger < ActiveRecord::Base
    has_many :tickets
    has_many :flights, through: :tickets

    # Finds an instance of Passenger whose username and password match the user's input
    def self.login
        puts "Enter 'exit' to exit login"
        puts "Enter your username: "
        username = gets.strip
        if username == "exit"
            return "exit"
        end
        puts "Enter your password: " 
        password = gets.strip
        if password == "exit"
            return "exit"
        end
        passenger = self.find_by(username: username, password: password)
        return passenger
    end 

    # Creates a new instance of a passenger and saves it in the passengers table
    def self.signup
        puts "Enter a username: "
        candidate_username = gets.strip

        # Directs new user to choose another username if the one that was entered is already taken by an existing user
        existing_pass = self.find_by(username: candidate_username)
        while existing_pass != nil
            puts "This username is taken. Enter in another username: "
            candidate_username = gets.strip
            existing_pass = self.find_by(username: candidate_username)
        end
        
        puts "Password: "
        pw = gets.strip
    
        puts "Enter your name: "
        name = gets.strip
    
        self.create({name: name, username: candidate_username, password: pw, balance: 0.0})
    end

    # Adds money to the user's balance
    def add_money_to_account(balance_to_add)
        self.balance += balance_to_add
        self.save
    end
    
    # Deducts money from the user's balance when the user books a flight
    def deduct_money_from_account(balance_to_deduct)
        self.balance -= balance_to_deduct
        self.save
    end

    # displays info from all tickets the user has booked
    def get_info_from_tickets
        puts "Here are your tickets\n"
        num = 1

        self.tickets.each {|t| 
            puts "#{num} #{t.info}"
            num += 1
        }
        puts "Press ENTER to continue"
        gets
    end

end
