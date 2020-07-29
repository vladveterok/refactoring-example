class Console
  include MoneyOperationsConsole

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

    case gets.chomp
    when 'create' then create
    when 'load' then load
    else exit
    end
  end

  def load
    return create_the_first_account unless accounts.any?

    puts 'Enter your login'
    login = gets.chomp
    puts 'Enter your password'
    password = gets.chomp

    return main_menu unless account.load(login, password).nil?

    puts 'There is no account with given credentials'
    console
  end

  def create_the_first_account
    puts 'There is no active accounts, do you want to be the first?[y/n]'
    gets.chomp == 'y' ? create : console
  end

  def create
    loop do
      account.name = name_input
      account.age = age_input
      account.login = login_input
      account.password = password_input
      break if @errors.empty?

      return_errors
    end
    account.create
    main_menu
  end

  def main_menu
    loop do
      puts "\nWelcome, #{account.current_account.name}" # #{account.current_account.name}
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
      break if command == 'exit'

      commands(command)
      # puts "Wrong command. Try again!\n" if commands(gets.chomp).nil? # (gets.chomp)
    end

  rescue BankErrors::BankError => e
    puts e.message
    retry
  end

  def commands(command)
    case command
    when 'SC' then show_cards
    when 'CC' then create_card
    when 'DC' then destroy_card
    when 'PM' then put_money
    when 'WM' then withdraw_money
    when 'SM' then send_money
    when 'DA' then destroy_account
    # else puts "Wrong command. Try again!\n"
    end
  end

  def create_card
    loop do
      puts 'You could create one of 3 card types'
      puts '- Usual card. 2% tax on card INCOME. 20$ tax on SENDING money from this card. 5% tax on WITHDRAWING money. For creation this card - press `usual`'
      puts '- Capitalist card. 10$ tax on card INCOME. 10% tax on SENDING money from this card. 4$ tax on WITHDRAWING money. For creation this card - press `capitalist`'
      puts '- Virtual card. 1$ tax on card INCOME. 1$ tax on SENDING money from this card. 12% tax on WITHDRAWING money. For creation this card - press `virtual`'
      puts '- For exit - press `exit`'

      card = gets.chomp

      # NEW LOGIC:
      exit if card == 'exit'
      account.create_card(card)
      break

    end
  end

  def destroy_card
    return puts "There is no active cards!\n" unless account.current_account.card.any?

    loop do
      puts 'If you want to delete:'
      show_cards_with_index
      puts "press `exit` to exit\n"

      answer = gets.chomp
      break if answer == 'exit'
      next puts "You entered wrong number!\n" unless (1..account.current_account.card.length).include? answer.to_i

      puts "Are you sure you want to delete #{account.current_account.card[answer.to_i - 1].number}?[y/n]"
      account.destroy_card(answer.to_i) if gets.chomp == 'y'
      break
    end
  end

  def show_cards
    return puts 'There is no active cards!' if account.current_account.card.empty?

    account.current_account.card.each { |card| puts "- #{card.number}, #{card.type}" }
  end

  def destroy_account
    puts 'Are you sure you want to destroy account?[y/n]'
    a = gets.chomp
    account.destroy_account if a == 'y'
  end

  private

  def name_input
    puts 'Enter your name'
    name = gets.chomp # .capitalize
    return name if name != '' && name.capitalize == name

    @errors.push('Your name must not be empty and starts with first upcase letter')
  end

  def age_input
    puts 'Enter your age'
    age = gets.chomp
    return age.to_i if age.to_i.is_a?(Integer) && age.to_i >= 23 && age.to_i <= 90

    @errors.push('Your Age must be greeter then 23 and lower then 90')
  end

  def login_input
    puts 'Enter your login'
    login = gets.chomp

    @errors.push('Login must present') if login == ''
    @errors.push('Login must be longer then 4 symbols') if login.length < 4
    @errors.push('Login must be shorter then 20 symbols') if login.length > 20

    return login unless account.accounts.map(&:login).include? login

    @errors.push('Such account is already exists')
  end

  #### MOVE errors into app?
  def password_input
    puts 'Enter your password'
    password = gets.chomp

    @errors.push('Password must present') if password == ''
    @errors.push('Password must be longer then 6 symbols') if password.length < 6
    @errors.push('Password must be shorter then 30 symbols') if password.length > 30
  end

  def choose_the_card(operation)
    account.current_account.card.any? ? (puts "Choose the card for #{operation}") : (return puts 'There is no active cards!')
    show_cards_with_index
    puts 'press "exit" to exit'
    gets.chomp
  end

  def show_cards_with_index
    return puts 'There is no active cards!' if account.current_account.card.empty?

    account.current_account.card.each_with_index do |card, index|
      puts "- #{card.number}, #{card.type}, press #{index + 1}"
    end
  end

  def accounts
    account.accounts
  end

  def return_errors
    @errors.each do |e|
      puts e
    end
    @errors = []
  end
end
