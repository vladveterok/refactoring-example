module MoneyOperations

  def withdraw_money(card, amount)
    card.withdraw_money(amount)
    new_accounts = []
    accounts.each do |account|
      if account.login == @current_account.login
        new_accounts.push(@current_account)
      else
        new_accounts.push(ac)
      end
    end
    File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml }
  end

  ######### MONEY METHOD
  def put_money(card, amount)
    card.put_money(amount)
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
  def send_money(sender_card, recipient_card, amount)
    sender_card.send_money(amount)
    recipient_card.put_money(amount)
    # sender_card.balance = sender_balance
    # @current_account.card[answer.to_i - 1] = sender_card
    new_accounts = []
    accounts.each do |ac|
      if ac.login == @current_account.login
        new_accounts.push(@current_account)
      elsif ac.card.map(&:number).include? recipient_card.number
        # recipient = ac
        # new_recipient_cards = []
        # recipient.card.each do |card|
        #  if card.number == recipient_card.number
        #    card.balance = recipient_balance
        #  end
        #  new_recipient_cards.push(card)
        # end
        # recipient.card = new_recipient_cards
        ac.card = recipient_card
        new_accounts.push(ac)
      end
    end
    File.open('accounts.yml', 'w') { |f| f.write new_accounts.to_yaml }
  end
end
