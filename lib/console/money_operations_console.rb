class Console
  module MoneyOperationsConsole
    include BankErrors

    def withdraw_money
      answer_card = choose_the_card('withdrawing:')
      return if answer_card == 'exit'

      card = current_card(answer_card)
      amount = ask_money_amount('withdraw')

      @current_account.withdraw_money(card, amount.to_i)
      puts I18n.t(:money_withdrawn, amount: amount, card: card.number,
                                    balance: card.balance, tax: card.withdraw_tax(amount.to_i))
    end

    def put_money
      answer_card = choose_the_card('putting:')
      return if answer_card == 'exit'

      card = current_card(answer_card)
      amount = ask_money_amount('put on your card')

      @current_account.put_money(card, amount.to_i)
      puts I18n.t(:money_put, amount: amount, card: card.number,
                              balance: card.balance, tax: card.withdraw_tax(amount.to_i))
    end

    def send_money
      answer_sender_card = choose_the_card('putting:')
      return if answer_sender_card == 'exit'

      card = current_card(answer_sender_card)
      recipient_card = ask_recipient_card

      amount = ask_money_amount('withdraw')

      @current_account.send_money(card, recipient_card, amount.to_i)
      puts I18n.t(:money_sent, amount: amount, card: recipient_card.number,
                              balance: card.balance, tax: card.withdraw_tax(amount.to_i))
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
end
