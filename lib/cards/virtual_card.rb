class VirtualCard < BasicCard

  # in cents
  TAX_PERCENT = {
    withdraw: 88,
    put: 0,
    sender: 0
  }.freeze

  TAX_FIXED = {
    withdraw: 0,
    put: 1,
    sender: 1
  }.freeze

  def initialize
    @balance = 150.00
  end

  def number
    @number ||= generate_card_number
  end
end
