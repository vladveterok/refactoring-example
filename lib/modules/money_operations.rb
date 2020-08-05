module MoneyOperations
  def withdraw_money(card, amount)
    card.withdraw_money(amount)
    update_card(card)
  end

  def put_money(card, amount)
    card.put_money(amount)
    update_card(card)
  end

  def send_money(sender_card, recipient_card, amount)
    sender_card.send_money(amount)
    recipient_card.put_money(amount)

    update_card(sender_card)
    update_card(recipient_card)
  end
end
