class Console
  def initialize
    @errors = []
    account
  end

  def account
    @account ||= Account.new
  end

  def console
    puts 'Hello, we are RubyG bank!'
    puts '- If you want to create account - press `create`'
    puts '- If you want to load account - press `load`'
    puts '- If you want to exit - press `exit`'

    answer = gets.chomp
    if answer == 'create'
      create
    elsif answer == 'load'
      load
    else
      exit
    end
  end

  def load
    loop do
      return create_the_first_account unless accounts.any?

      puts 'Enter your login'
      login = gets.chomp
      puts 'Enter your password'
      password = gets.chomp

      break unless account.load(login, password).nil?
      puts 'There is no account with given credentials'
    end
    main_menu
  end

  def create_the_first_account
    puts 'There is no active accounts, do you want to be the first?[y/n]'
    if gets.chomp == 'y'
      return create
    else
      return console
    end
  end

  def create
    loop do
      account.name = name_input
      account.age = age_input
      account.login = login_input
      account.password = password_input
      break if @errors.empty?
      @errors.each do |e|
        puts e
      end
      @errors = []
    end
    account.create
    main_menu
  end

  def name_input
    puts 'Enter your name'
    name = gets.chomp # .capitalize
    unless name != '' && name[0].upcase == name[0]
      @errors.push('Your name must not be empty and starts with first upcase letter')
    end
    name
  end

  def age_input
    puts 'Enter your age'
    age = gets.chomp
    if age.to_i.is_a?(Integer) && age.to_i >= 23 && age.to_i <= 90
      age = age.to_i
    else
      @errors.push('Your Age must be greeter then 23 and lower then 90')
    end
    age
  end

  def login_input
    puts 'Enter your login'
    login = gets.chomp
    if login == ''
      @errors.push('Login must present')
    end

    if login.length < 4
      @errors.push('Login must be longer then 4 symbols')
    end

    if login.length > 20
      @errors.push('Login must be shorter then 20 symbols')
    end

    if accounts.map { |a| a.login }.include? login
      @errors.push('Such account is already exists')
    end
    login
  end

  def password_input
    puts 'Enter your password'
    password = gets.chomp
    if password == ''
      @errors.push('Password must present')
    end

    if password.length < 6
      @errors.push('Password must be longer then 6 symbols')
    end

    if password.length > 30
      @errors.push('Password must be shorter then 30 symbols')
    end
    password
  end

  def main_menu
    loop do
      puts "\nWelcome, #{account.current_account.name}"
      puts 'If you want to:'
      puts '- show all cards - press SC'
      puts '- create card - press CC'
      puts '- destroy card - press DC'
      puts '- put money on card - press PM'
      puts '- withdraw money on card - press WM'
      puts '- send money to another card  - press SM'
      puts '- destroy account - press `DA`'
      puts '- exit from account - press `exit`'

      commands(gets.chomp)
    end
  end

  def commands(command)
    if command == 'SC' || command == 'CC' || command == 'DC' || command == 'PM' || command == 'WM' || command == 'SM' || command == 'DA' || command == 'exit'
      if command == 'SC'
        account.show_cards
      elsif command == 'CC'
        account.create_card
      elsif command == 'DC'
        account.destroy_card
      elsif command == 'PM'
        account.put_money
      elsif command == 'WM'
        account.withdraw_money
      elsif command == 'SM'
        account.send_money
      elsif command == 'DA'
        account.destroy_account
        exit
      elsif command == 'exit'
        exit
      end
    else
      puts "Wrong command. Try again!\n"
    end
  end



  private

  def accounts
    account.accounts
  end
end
