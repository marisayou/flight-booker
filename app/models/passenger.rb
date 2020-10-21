class Passenger < ActiveRecord::Base
    has_many :tickets
    has_many :flights, through: :tickets

    def self.login
        puts "Enter your username: "
        username = gets.strip
        puts "Enter your password: " 
        password = gets.strip  # TODO: Is there a way to get user input string without showing it on the console? 
        passenger = self.find_by(username: username, password: password)
        return passenger
    end 

    def self.signup
        puts "Enter a username: "
        candidate_username = gets.strip
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
    
        p1 = self.create({name: name, username: candidate_username, password: pw, balance: 0.00})
        
    end


    def add_money_to_account(balance_to_add)
        self.balance += balance_to_add
        self.save
    end
    
    def deduct_money_from_account(balance_to_deduct)
        self.balance -= balance_to_deduct
        self.save
    end

    def get_info_from_tickets
        puts "Here are your tickets\n"
        num = 1
        self.tickets.each do |t| 
            puts "#{num} #{t.info}"
            num += 1
        end
        puts "Press ENTER to continue"
        gets
    end
end
