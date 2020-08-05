module FileLoader
  def update_file(card)
    new_accounts = []
    # accounts.each do |account|
    #  binding.pry
    #  if account.card.map(&:number).include? card.number
    #    account.card.collect! { |stored_card| stored_card.number == card.number ? card : stored_card }
    #  end
    #  new_accounts.push(account)
    # end

    accounts.each do |account|
      account.card.collect! { |stored_card| stored_card.number == card.number ? card : stored_card }
      new_accounts.push(account)
    end

    save_in_file(new_accounts) # File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml }
  end

  def update_account
    new_accounts = []
    accounts.each do |account|
      account.login == @current_account.login ? new_accounts.push(@current_account) : new_accounts.push(account)
    end
    save_in_file(new_accounts)
  end

  def accounts
    File.exist?('accounts.yml') ? YAML.load_file('accounts.yml') : []
  end

  def save_in_file(data)
    File.open(@file_path, 'w') { |f| f.write data.to_yaml }
  end
end
