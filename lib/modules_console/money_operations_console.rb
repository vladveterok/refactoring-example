module MoneyOperationsConsole
  include BankErrors
  #### ERRORS INTO APPS?
  def withdraw_money
    answer_card = choose_the_card('withdrawing:')
    return if answer_card == 'exit'
    raise WrongNumberError unless (1..@current_account.card.length).include? answer_card.to_i

    current_card = current_card(answer_card.to_i - 1)

    # puts 'Input the amount of money you want to withdraw'
    # answer_amount = gets.chomp
    # raise WrongAmountError unless answer_amount.to_i.positive?
    answer_amount = ask_money_amount('withdraw')

    @current_account.withdraw_money(current_card, answer_amount.to_i)
    puts "Money #{answer_amount.to_i} withdrawed from #{current_card.number}$. Money left: #{current_card.balance}$. Tax: #{current_card.withdraw_tax(answer_amount.to_i)}$"
  end

  def ask_money_amount(option)
    puts I18n.t(:ask_amount, option: option)
    (amount = gets.chomp).to_i.positive? ? amount : (raise WrongAmountError)
  end

  #### ERRORS INTO APP?
  def put_money
    answer_card = choose_the_card('putting:')
    return if answer_card == 'exit'
    raise WrongNumberError unless (1..current_account_cards.length).include? answer_card.to_i

    current_card = current_card(answer_card.to_i - 1)

    # puts 'Input the amount of money you want to put on your card'
    # answer_amount = gets.chomp
    # raise WrongAmountError unless answer_amount.to_i.positive?
    answer_amount = ask_money_amount('put on your card')

    @current_account.put_money(current_card, answer_amount.to_i)
    puts "Money #{answer_amount&.to_i.to_i} was put on #{current_card.number}. Balance: #{current_card.balance}. Tax: #{current_card.put_tax(answer_amount.to_i)}"
  end

  #### ERRORS INTO APP?
  def send_money
    answer_sender_card = choose_the_card('putting:') # puts 'Choose the card for sending:'
    return if answer_sender_card == 'exit'
    return puts 'Choose correct card' unless (1..@current_account.card.length).include? answer_sender_card.to_i

    sender_card = @current_account.card[answer_sender_card.to_i - 1]
    recipient_card = ask_recipient_card

    # puts 'Input the amount of money you want to withdraw'
    # answer_amount = gets.chomp
    answer_amount = ask_money_amount('withdraw')

    return puts 'You entered wrong number!' unless answer_amount.to_i.positive?

    account.current_account.send_money(sender_card, recipient_card, answer_amount.to_i)
    puts "Money #{answer_amount.to_i}$ was put on #{recipient_card.number}. Balance: #{sender_card.balance}. Tax: #{sender_card.sender_tax(answer_amount.to_i)}$"
  end

  def current_card(number)
    @current_account.card[number]
  end

  def current_account_cards
    @current_account.card
  end

  def ask_recipient_card
    puts 'Enter the recipient card:'
    answer_recipient_card = gets.chomp
    raise WrongNumberError unless answer_recipient_card.length > 15 && answer_recipient_card.length < 17

    find_card(answer_recipient_card)
  end

  def find_card(card)
    all_cards = account.accounts.map(&:card).flatten
    return puts I18n.t(:no_such_card, card: card) unless all_cards.map(&:number).any? card

    all_cards.select { |stored_card| stored_card.number == card }.first
  end
end
