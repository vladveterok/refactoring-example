module MoneyOperations
  def withdraw_money(card, amount)
    card.withdraw_money(amount)

    update_file(card)
  end

  def put_money(card, amount)
    card.put_money(amount)

    update_file(card)
  end

  def send_money(sender_card, recipient_card, amount)
    sender_card.send_money(amount)
    recipient_card.put_money(amount)

    update_file(sender_card)
    update_file(recipient_card)
  end
end
