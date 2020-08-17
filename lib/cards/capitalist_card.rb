class CapitalistCard < BasicCard
  attr_reader :balance

  # in cents
  TAX_PERCENT = {
    withdraw: 4,
    put: 0,
    sender: 10
  }.freeze

  TAX_FIXED = {
    withdraw: 0,
    put: 10,
    sender: 0
  }.freeze

  def initialize
    @balance = 100.00
    @number = generate_card_number
  end

  def withdraw_tax(amount)
    tax(amount, TAX_PERCENT[:withdraw], TAX_FIXED[:withdraw])
  end

  def put_tax(amount)
    tax(amount, TAX_PERCENT[:put], TAX_FIXED[:put])
  end

  def sender_tax(amount)
    tax(amount, TAX_PERCENT[:sender], TAX_FIXED[:sender])
  end
end
