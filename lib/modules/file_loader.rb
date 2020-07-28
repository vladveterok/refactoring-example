module FileLoader
  def update_file(card)
    new_accounts = []

    accounts.each do |account|
      if account.card.map(&:number).include? card.number
        account.card.collect! { |stored_card| stored_card.number == card.number ? card : stored_card }
      end
      new_accounts.push(account)
    end

    File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml }
  end
end
