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

  def login_input
    puts 'Enter your login'
    login = gets.chomp

    @errors.push('Login must present') if login == ''
    @errors.push('Login must be longer then 4 symbols') if login.length < 4
    @errors.push('Login must be shorter then 20 symbols') if login.length > 20

    return login unless account.accounts.map(&:login).include? login

    @errors.push('Such account is already exists')
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
  end

  def commands(command)
    if command == 'SC' || command == 'CC' || command == 'DC' || command == 'PM' || command == 'WM' || command == 'SM' || command == 'DA' || command == 'exit'
      if command == 'SC'
        show_cards
      elsif command == 'CC'
        create_card # account.create_card
      elsif command == 'DC'
        destroy_card # account.destroy_card
      elsif command == 'PM'
        put_money # account.put_money
      elsif command == 'WM'
        withdraw_money # account.withdraw_money
      elsif command == 'SM'
        send_money # account.send_money
      elsif command == 'DA'
        destroy_account # account.destroy_account
        exit
      elsif command == 'exit'
        exit
      end
    else
      puts "Wrong command. Try again!\n"
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
      if card == 'usual' || card == 'capitalist' || card == 'virtual'
        if card == 'usual'
          account.current_account.card << UsualCard.new
        elsif card == 'capitalist'
          account.current_account.card << CapitalistCard.new
        elsif card == 'virtual'
          account.current_account.card << VirtualCard.new
        end
        account.create_card
        break
      else
        puts "Wrong card type. Try again!\n"
      end

      # break unless account.load(login, password).nil?
      # puts 'There is no account with given credentials'
    end
  end

  def destroy_card
    if account.current_account.card.any?
      loop do
        puts 'If you want to delete:'
        show_cards_with_index

        puts "press `exit` to exit\n"
        answer = gets.chomp
        break if answer == 'exit'
        if (1..account.current_account.card.length).include? answer.to_i
          puts "Are you sure you want to delete #{account.current_account.card[answer.to_i - 1].number}?[y/n]"
          answer2 = gets.chomp
          if answer2 == 'y'
            account.destroy_card(answer.to_i)
            break
          else
            return
          end
        else
          puts "You entered wrong number!\n"
        end
      end
    else
      puts "There is no active cards!\n"
    end
  end

  def show_cards
    if !account.show_cards.empty?
      account.show_cards.each { |card| puts "- #{card.number}, #{card.type}" }
    else
      puts 'There is no active cards!'
    end
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

  def show_cards_with_index
    if !account.show_cards.empty?
      account.show_cards.each_with_index do |card, index|
        puts "- #{card.number}, #{card.type}, press #{index + 1}"
      end
    else
      puts 'There is no active cards!'
    end
  end

  def accounts
    account.accounts
  end

  def withdraw_money
    account.withdraw_money
  end

  def put_money
    account.put_money
  end

  def send_money
    account.send_money
  end
end
