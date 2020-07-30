module MoneyOperationsConsole
  include BankErrors

  def withdraw_money
    answer_card = choose_the_card('withdrawing:')
    return if answer_card == 'exit'

    # raise WrongNumberError unless (1..@current_account.card.length).include? answer_card.to_i

    card = current_card(answer_card.to_i - 1)
    amount = ask_money_amount('withdraw')

    @current_account.withdraw_money(card, amount.to_i)
    puts I18n.t(:money_withdrawn, amount: amount, card: card.number, balance: card.balance, tax: card.withdraw_tax(amount.to_i))
    # show_operation_result(answer_amount, current_card, method(:withdraw_money))
  end

  def put_money
    answer_card = choose_the_card('putting:')
    return if answer_card == 'exit'

    # raise WrongNumberError unless (1..current_account_cards.length).include? answer_card.to_i

    card = current_card(answer_card.to_i - 1)
    amount = ask_money_amount('put on your card')

    @current_account.put_money(card, amount.to_i)
    puts I18n.t(:money_put, amount: amount, card: card.number, balance: card.balance, tax: card.withdraw_tax(amount.to_i))
    # show_operation_result(answer_amount, current_card, method(:put_money))
  end

  def show_operation_result(amount, card, method, recip_card = nil)
    case method
    when :withdraw_money
      puts I18n.t(:money_withdrawn, amount: amount, card: card.number, balance: card.balance, tax: card.withdraw_tax(amount))
    when :put_money
      puts I18n.t(:money_put, amount: amount, card: card.number, balance: card.balance, tax: card.withdraw_tax(amount))
    when :send_money
      puts I18n.t(:money_sent, amount: amount, card: recip_card.number, balance: card.balance, tax: card.withdraw_tax(amount))
    end
  end

  def send_money
    answer_sender_card = choose_the_card('putting:')
    return if answer_sender_card == 'exit'

    # raise WrongNumberError unless (1..@current_account.card.length).include? answer_sender_card.to_i

    card = current_card(answer_sender_card.to_i - 1)
    recipient_card = ask_recipient_card

    amount = ask_money_amount('withdraw')

    # return puts 'You entered wrong number!' unless answer_amount.to_i.positive?

    @current_account.send_money(card, recipient_card, amount.to_i)
    puts I18n.t(:money_sent, amount: amount, card: recipient_card.number, balance: card.balance, tax: card.withdraw_tax(amount.to_i))
    # show_operation_result(answer_amount, current_card, method(:send_money), recipient_card)
  end

  def current_card(number)
    @current_account.card[number]
  end

  def current_account_cards
    @current_account.card
  end

  def ask_money_amount(option)
    puts I18n.t(:ask_amount, option: option)
    (amount = gets.chomp).to_i.positive? ? amount : (raise WrongAmountError)
  end

  def ask_recipient_card
    puts I18n.t(:enter_recipient)
    answer_recipient_card = gets.chomp
    raise WrongNumberError unless answer_recipient_card.length > 15 && answer_recipient_card.length < 17

    find_recipient_card(answer_recipient_card)
  end

  def find_recipient_card(card)
    all_cards = account.accounts.map(&:card).flatten
    return puts I18n.t(:no_such_card, card: card) unless all_cards.map(&:number).any? card

    all_cards.select { |stored_card| stored_card.number == card }.first
  end
end
