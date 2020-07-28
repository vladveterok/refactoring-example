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

    new_accounts = []
    accounts.each do |ac|
      if ac.login == @current_account.login
        new_accounts.push(@current_account)
      elsif ac.card.map(&:number).include? recipient_card.number
        ac.card = recipient_card
        new_accounts.push(ac)
      end
    end
    File.open('accounts.yml', 'w') { |f| f.write new_accounts.to_yaml }
  end
end
