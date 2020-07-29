module MoneyOperationsConsole
  #### ERRORS INTO APPS?
  def withdraw_money
    answer_card = choose_the_card('withdrawing:')
    return if answer_card == 'exit'
    return puts 'You entered wrong number!' unless (1..account.current_account.card.length).include? answer_card.to_i

    current_card = account.current_account.card[answer_card.to_i - 1]

    puts 'Input the amount of money you want to withdraw'
    answer_amount = gets.chomp
    return puts 'You must input correct amount of $' unless answer_amount.to_i.positive?

    account.current_account.withdraw_money(current_card, answer_amount.to_i)
    puts "Money #{answer_amount.to_i} withdrawed from #{current_card.number}$. Money left: #{current_card.balance}$. Tax: #{current_card.withdraw_tax(answer_amount.to_i)}$"
  end

  #### ERRORS INTO APP?
  def put_money
    answer_card = choose_the_card('putting:')
    return if answer_card == 'exit'
    return puts 'You entered wrong number!' unless (1..account.current_account.card.length).include? answer_card.to_i

    current_card = account.current_account.card[answer_card.to_i - 1]

    puts 'Input the amount of money you want to put on your card'
    answer_amount = gets.chomp
    return puts 'You must input correct amount of money' unless answer_amount.to_i.positive?

    account.current_account.put_money(current_card, answer_amount.to_i)
    puts "Money #{answer_amount&.to_i.to_i} was put on #{current_card.number}. Balance: #{current_card.balance}. Tax: #{current_card.put_tax(answer_amount.to_i)}"
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
end