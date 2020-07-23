require 'yaml'
require 'pry'

class Account
  include MoneyOperations

  attr_accessor :login, :name, :age, :card, :password, :file_path, :current_account

  def initialize
    # @errors = []
    @file_path = 'accounts.yml'

    @name = nil
    @login = nil
    @age = 0
    @password = nil
    @file_path = 'accounts.yml'
    @card = []
    @current_account = nil
  end

=begin
  def console
      puts 'Hello, we are RubyG bank!'
      puts '- If you want to create account - press `create`'
      puts '- If you want to load account - press `load`'
      puts '- If you want to exit - press `exit`'

    # FIRST SCENARIO. IMPROVEMENT NEEDED

    a = gets.chomp

    if a == 'create'
      create
    elsif a == 'load'
      load
    else
      exit
    end
  end
=end

  def create
   # loop do
   #   name_input
   #   age_input
   #   login_input
   #   password_input
   #   break unless @errors.length != 0
   #   @errors.each do |e|
   #     puts e
   #   end
   #  @errors = []
   # end

    # @card = []
    new_accounts = accounts << self
    @current_account = self
    File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml } #Storing
    # main_menu
  end

  def load(login, password)
    # loop do
    #  return create_the_first_account unless account.accounts.any?

    #  puts 'Enter your login'
    #  login = gets.chomp
    #  puts 'Enter your password'
    #  password = gets.chomp

      if accounts.map { |a| { login: a.login, password: a.password } }.include?({ login: login, password: password })
        @current_account = accounts.select { |a| login == a.login }.first
        # break
      # else WITH SOME ERROR!!!!!!!!!!!!
        # puts 'There is no account with given credentials'
        # next
      end
    # end
    # main_menu
  end

=begin
  def create_the_first_account
    puts 'There is no active accounts, do you want to be the first?[y/n]'
    if gets.chomp == 'y'
      return create
    else
      return console
    end
  end
=end
=begin
  def main_menu
    loop do
      puts "\nWelcome, #{@current_account.name}"
      puts 'If you want to:'
      puts '- show all cards - press SC'
      puts '- create card - press CC'
      puts '- destroy card - press DC'
      puts '- put money on card - press PM'
      puts '- withdraw money on card - press WM'
      puts '- send money to another card  - press SM'
      puts '- destroy account - press `DA`'
      puts '- exit from account - press `exit`'

      command = gets.chomp

      if command == 'SC' || command == 'CC' || command == 'DC' || command == 'PM' || command == 'WM' || command == 'SM' || command == 'DA' || command == 'exit'
        if command == 'SC'
          show_cards
        elsif command == 'CC'
          create_card
        elsif command == 'DC'
          destroy_card
        elsif command == 'PM'
          put_money
        elsif command == 'WM'
          withdraw_money
        elsif command == 'SM'
          send_money
        elsif command == 'DA'
          destroy_account
          exit
        elsif command == 'exit'
          exit
          break
        end
      else
        puts "Wrong command. Try again!\n"
      end
    end
  end
=end
  ################################ CARD CREATION
  def create_card
    # loop do
    #  puts 'You could create one of 3 card types'
    #  puts '- Usual card. 2% tax on card INCOME. 20$ tax on SENDING money from this card. 5% tax on WITHDRAWING money. For creation this card - press `usual`'
    #  puts '- Capitalist card. 10$ tax on card INCOME. 10% tax on SENDING money from this card. 4$ tax on WITHDRAWING money. For creation this card - press `capitalist`'
    #  puts '- Virtual card. 1$ tax on card INCOME. 1$ tax on SENDING money from this card. 12% tax on WITHDRAWING money. For creation this card - press `virtual`'
    #  puts '- For exit - press `exit`'

    #  ct = gets.chomp
      # if ct == 'usual' || ct == 'capitalist' || ct == 'virtual'
        # if ct == 'usual'
        #  card = UsualCard.new
        # elsif ct == 'capitalist'
        #  card = CapitalistCard.new
        # elsif ct == 'virtual'
        #  card = VirtualCard.new
        # end
        cards = @current_account.card # << card
        @current_account.card = cards #important!!!
        new_accounts = []
        accounts.each do |ac|
          if ac.login == @current_account.login
            new_accounts.push(@current_account)
          else
            new_accounts.push(ac)
          end
        end
        File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml } #Storing
        # break
      # else
        # puts "Wrong card type. Try again!\n"
      # end
    # end
  end
  ################################ CARD CREATION ENDS

  def destroy_card(card_number)
    # loop do
      # if @current_account.card.any?
        # puts 'If you want to delete:'

        # @current_account.card.each_with_index do |c, i|
        #   puts "- #{c[:number]}, #{c[:type]}, press #{i + 1}"
        # end
        # puts "press `exit` to exit\n"
        # answer = gets.chomp
        # break if answer == 'exit'
        # if answer&.to_i.to_i <= @current_account.card.length && answer&.to_i.to_i > 0
          # puts "Are you sure you want to delete #{@current_account.card[answer&.to_i.to_i - 1][:number]}?[y/n]"
          # a2 = gets.chomp
          # if a2 == 'y'
            @current_account.card.delete_at(card_number - 1)
            new_accounts = []
            accounts.each do |ac|
              if ac.login == @current_account.login
                new_accounts.push(@current_account)
              else
                new_accounts.push(ac)
              end
            end
            File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml } #Storing
          # break
          # else
          #   return
          # end
        # else
        #  puts "You entered wrong number!\n"
        # end
      # else
      #  puts "There is no active cards!\n"
      #  break
      # end
    # end
  end

  def show_cards ############# REPLACE WITH all_cards
    # if @current_account.card.any?
      @current_account.card # .each do |c|
      #  puts "- #{c.number}, #{c.type}"
      # end
    # else
    #  puts "There is no active cards!\n"
    # end
  end

  def destroy_account
    puts 'Are you sure you want to destroy account?[y/n]'
    a = gets.chomp
    if a == 'y'
      new_accounts = []
      accounts.each do |ac|
        if ac.login == @current_account.login
        else
          new_accounts.push(ac)
        end
      end
      File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml } #Storing
    end
  end

  def accounts
    if File.exists?('accounts.yml')
      YAML.load_file('accounts.yml')
    else
      []
    end
  end

  private
=begin
  def name_input
    puts 'Enter your name'
    @name = gets.chomp
    unless @name != '' && @name[0].upcase == @name[0]
      @errors.push('Your name must not be empty and starts with first upcase letter')
    end
  end
=end

=begin
  def login_input
    puts 'Enter your login'
    @login = gets.chomp
    if @login == ''
      @errors.push('Login must present')
    end

    if @login.length < 4
      @errors.push('Login must be longer then 4 symbols')
    end

    if @login.length > 20
      @errors.push('Login must be shorter then 20 symbols')
    end

    if accounts.map { |a| a.login }.include? @login
      @errors.push('Such account is already exists')
    end
  end
=end

=begin
  def password_input
    puts 'Enter your password'
    @password = gets.chomp
    if @password == ''
      @errors.push('Password must present')
    end

    if @password.length < 6
      @errors.push('Password must be longer then 6 symbols')
    end

    if @password.length > 30
      @errors.push('Password must be shorter then 30 symbols')
    end
  end
=end

=begin
  def age_input
    puts 'Enter your age'
    @age = gets.chomp
    if @age.to_i.is_a?(Integer) && @age.to_i >= 23 && @age.to_i <= 90
      @age = @age.to_i
    else
      @errors.push('Your Age must be greeter then 23 and lower then 90')
    end
  end
=end
end
