module MoneyOperations

  def withdraw_money(card, amount)
    card.withdraw_money(amount)
    new_accounts = []
    accounts.each do |ac|
      if ac.login == @current_account.login
        new_accounts.push(@current_account)
      else
        new_accounts.push(ac)
      end
    end
    File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml }
  end

  ######### MONEY METHOD
  def put_money(card, amount)
    # puts 'Choose the card for putting:'

    # if @current_account.card.any?
      # @current_account.card.each_with_index do |c, i|
      #   puts "- #{c.number}, #{c.type}, press #{i + 1}"
      # end
      # puts "press `exit` to exit\n"
      # loop do
        # answer = gets.chomp
        # break if answer == 'exit'
        # if answer&.to_i <= @current_account.card.length && answer.to_i > 0
          # current_card = @current_account.card[answer.to_i - 1]
          # loop do
          #  puts 'Input the amount of money you want to put on your card'
          #  a2 = gets.chomp
            # if a2.to_i > 0
              # if current_card.put_tax(a2.to_i) >= a2.to_i
              #  puts 'Your tax is higher than input amount'
              #  return
              # else
                card.put_money(amount)
                # new_money_amount = current_card.balance + a2.to_i - current_card.put_tax(a2.to_i)
                # current_card.balance = new_money_amount
                # @current_account.card[answer.to_i - 1] = current_card
                new_accounts = []
                accounts.each do |ac|
                  if ac.login == @current_account.login
                    new_accounts.push(@current_account)
                  else
                    new_accounts.push(ac)
                  end
                end
                File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml }
                # puts "Money #{a2&.to_i.to_i} was put on #{current_card.number}. Balance: #{current_card.balance}. Tax: #{put_tax(current_card.type, current_card.balance, current_card.number, a2&.to_i.to_i)}"
                # return
             #  end
            # else
            #  puts 'You must input correct amount of money'
            #  return
            # end
          # end
        # else
        #  puts "You entered wrong number!\n"
        #  return
        # end
      # end
    # else
      # puts "There is no active cards!\n"
    # end
  end

  ######### MONEY METHOD
  def send_money
    puts 'Choose the card for sending:'

    if @current_account.card.any?
      @current_account.card.each_with_index do |c, i|
        puts "- #{c.number}, #{c.type}, press #{i + 1}"
      end
      puts "press `exit` to exit\n"
      answer = gets.chomp
      exit if answer == 'exit'
      if answer&.to_i.to_i <= @current_account.card.length && answer&.to_i.to_i > 0
        sender_card = @current_account.card[answer&.to_i.to_i - 1]
      else
        puts 'Choose correct card'
        return
      end
    else
      puts "There is no active cards!\n"
      return
    end

    puts 'Enter the recipient card:'
    a2 = gets.chomp
    if a2.length > 15 && a2.length < 17
      all_cards = accounts.map(&:card).flatten
      if all_cards.select { |card| card.number == a2 }.any?
        recipient_card = all_cards.select { |card| card.number == a2 }.first
      else
        puts "There is no card with number #{a2}\n"
        return
      end
    else
      puts 'Please, input correct number of card'
      return
    end

    loop do
      puts 'Input the amount of money you want to withdraw'
      a3 = gets.chomp
      if a3.to_i.positive?
        sender_balance = sender_card.balance - a3.to_i - sender_card.sender_tax(a3.to_i)
        recipient_balance = recipient_card.balance + a3.to_i - recipient_card.put_tax(a3.to_i)

        if sender_balance.negative?
          puts "You don't have enough money on card for such operation"
        elsif put_tax(recipient_card.type, recipient_card.balance, recipient_card.number, a3&.to_i.to_i) >= a3.to_i
          puts 'There is no enough money on sender card'
        else
          sender_card.balance = sender_balance
          @current_account.card[answer&.to_i.to_i - 1] = sender_card
          new_accounts = []
          accounts.each do |ac|
            if ac.login == @current_account.login
              new_accounts.push(@current_account)
            elsif ac.card.map { |card| card.number }.include? a2
              recipient = ac
              new_recipient_cards = []
              recipient.card.each do |card|
                if card.number == a2
                  card.balance = recipient_balance
                end
                new_recipient_cards.push(card)
              end
              recipient.card = new_recipient_cards
              new_accounts.push(recipient)
            end
          end
          File.open('accounts.yml', 'w') { |f| f.write new_accounts.to_yaml } #Storing
          puts "Money #{a3&.to_i.to_i}$ was put on #{sender_card.number}. Balance: #{recipient_balance}. Tax: #{put_tax(sender_card.type, sender_card.balance, sender_card.number, a3&.to_i.to_i)}$\n"
          puts "Money #{a3&.to_i.to_i}$ was put on #{a2}. Balance: #{sender_balance}. Tax: #{sender_tax(sender_card.type, sender_card.balance, sender_card.number, a3&.to_i.to_i)}$\n"
          break
        end
      else
        puts 'You entered wrong number!\n'
      end
    end
  end
end
