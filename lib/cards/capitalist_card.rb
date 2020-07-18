class CapitalistCard < BasicCard
  
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
  end

  def card_number
    @card_number ||= generate_card_number
  end
end
