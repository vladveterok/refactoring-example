class UsualCard < BasicCard
  attr_reader :balance

  # in cents
  TAX_PERCENT = {
    withdraw: 5,
    put: 2,
    sender: 0
  }.freeze

  TAX_FIXED = {
    withdraw: 0,
    put: 0,
    sender: 20
  }.freeze

  def initialize
    @balance = 50.00
    @number = generate_card_number
  end

  # def number
  #  @number ||= generate_card_number
  # end

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
