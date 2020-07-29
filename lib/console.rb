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

  #### MOVE errors into app?
  def password_input
    puts 'Enter your password'
    password = gets.chomp

    @errors.push('Password must present') if password == ''
    @errors.push('Password must be longer then 6 symbols') if password.length < 6
    @errors.push('Password must be shorter then 30 symbols') if password.length > 30

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

      # NEW LOGIC:
      exit if card == 'exit'
      account.create_card(card)
      break
      # if card == 'usual' || card == 'capitalist' || card == 'virtual'
      #  if card == 'usual'
      #    account.current_account.card << UsualCard.new
      #  elsif card == 'capitalist'
      #    account.current_account.card << CapitalistCard.new
      #  elsif card == 'virtual'
      #    account.current_account.card << VirtualCard.new
      #  end
      #  account.create_card
      #  break
      # else
      #  puts "Wrong card type. Try again!\n"
      # end

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
    if !account.current_account.card.empty?
      account.current_account.card.each { |card| puts "- #{card.number}, #{card.type}" }
    else
      puts 'There is no active cards!'
    end
  end

  def destroy_account
    puts 'Are you sure you want to destroy account?[y/n]'
    a = gets.chomp
    account.destroy_account if a == 'y'
  end

  #### ERRORS INTO APPS?
  def withdraw_money
    puts 'Choose the card for withdrawing:'

    if account.current_account.card.any?
      show_cards_with_index
      puts "press `exit` to exit\n"

      loop do
        answer_card = gets.chomp
        break if answer_card == 'exit'

        if answer_card.to_i <= account.current_account.card.length && answer_card.to_i.positive?
          current_card = account.current_account.card[answer_card.to_i - 1]
          loop do
            puts 'Input the amount of money you want to withdraw'
            answer_amount = gets.chomp
            if answer_amount.to_i.positive?
              ##### CALL LOGIC STARTS
              account.current_account.withdraw_money(current_card, answer_amount.to_i)
              ##### CALL LOGIC ENDS
              puts "Money #{answer_amount.to_i} withdrawed from #{current_card.number}$. Money left: #{current_card.balance}$. Tax: #{current_card.withdraw_tax(answer_amount.to_i)}$"
              return
            else
              puts 'You must input correct amount of $'
              return
            end
          end
        else
          puts "You entered wrong number!\n"
          return
        end
      end
    else
      puts "There is no active cards!\n"
    end
  end

  #### ERRORS INTO APP?
  def put_money
    puts 'Choose the card for putting:'

    if account.current_account.card.any?
      show_cards_with_index

      puts "press `exit` to exit\n"
      loop do
        answer_card = gets.chomp
        break if answer_card == 'exit'

        if answer_card.to_i <= account.current_account.card.length && answer_card.to_i.positive?
          current_card = account.current_account.card[answer_card.to_i - 1]
          loop do
            puts 'Input the amount of money you want to put on your card'
            answer_amount = gets.chomp
            if answer_amount.to_i.positive?
              account.current_account.put_money(current_card, answer_amount.to_i)
              puts "Money #{answer_amount&.to_i.to_i} was put on #{current_card.number}. Balance: #{current_card.balance}. Tax: #{current_card.put_tax(answer_amount.to_i)}"
              return
            else
              puts 'You must input correct amount of money'
              return
            end
          end
        else
          puts "You entered wrong number!\n"
          return
        end
      end
    else
      puts "There is no active cards!\n"
    end
  end

  #### ERRORS INTO APP?
  def send_money
    puts 'Choose the card for sending:'

    if account.current_account.card.any?
      show_cards_with_index

      puts "press `exit` to exit\n"
      answer_sender_card = gets.chomp
      exit if answer_sender_card == 'exit'

      if answer_sender_card.to_i <= account.current_account.card.length && answer_sender_card.to_i.positive?
        sender_card = account.current_account.card[answer_sender_card.to_i - 1]
      else
        puts 'Choose correct card'
        return
      end
    else
      puts "There is no active cards!\n"
      return
    end

    puts 'Enter the recipient card:'
    answer_recipient_card = gets.chomp
    if answer_recipient_card.length > 15 && answer_recipient_card.length < 17
      all_cards = account.accounts.map(&:card).flatten
      if all_cards.map(&:number).any? answer_recipient_card # all_cards.select { |card| card.number == answer_recipient_card }.any?
        recipient_card = all_cards.select { |card| card.number == answer_recipient_card }.first
      else
        puts "There is no card with number #{answer_recipient_card}\n"
        return
      end
    else
      puts 'Please, input correct number of card'
      return
    end

    loop do
      puts 'Input the amount of money you want to withdraw'

      answer_amount = gets.chomp

      return puts 'You entered wrong number!\n' unless answer_amount.to_i.positive?

      if answer_amount.to_i.positive? # sender_balance.negative?
        account.current_account.send_money(sender_card, recipient_card, answer_amount.to_i)
        # puts "Money #{answer_amount.to_i}$ was put on #{sender_card.number}. Balance: #{recipient_balance}. Tax: #{put_tax(sender_card.type, sender_card.balance, sender_card.number, answer_amount.to_i)}$\n"
        # puts "Money #{answer_amount.to_i}$ was put on #{answer_recipient_card}. Balance: #{sender_balance}. Tax: #{sender_tax(sender_card.type, sender_card.balance, sender_card.number, answer_amount.to_i)}$\n"
        puts "Money #{answer_amount.to_i}$ was put on #{recipient_card.number}. Balance: #{sender_card.balance}. Tax: #{sender_card.sender_tax(answer_amount.to_i)}$\n"
        break
      else
        puts 'You entered wrong number!\n'
      end
    end
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
    if !account.current_account.card.empty?
      account.current_account.card.each_with_index do |card, index|
        puts "- #{card.number}, #{card.type}, press #{index + 1}"
      end
    else
      puts 'There is no active cards!'
    end
  end

  def accounts
    account.accounts
  end
end
