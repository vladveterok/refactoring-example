class UsualCard < BasicCard
  TAX_PERCENT = {
    withdraw: 5,
    put: 2,
    sender: 0
  }

  TAX_FIXED = {
    withdraw: 0,
    put: 0,
    sender: 20 
  }

  def initialize
    @balance = 50.00
  end

  def card_number
    @card_number ||= generate_card_number 
  end

  def withdraw_tax(amount:)
    tax(amount, withdraw_tax_percent)
  end

  def put_tax(amount:)
    tax(amount, put_tax_percent)
  end

  def sender_tax(amount:)
    tax(amount, sender_tax_percent)
  end

  private

end

