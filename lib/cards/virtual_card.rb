class VirtualCard < BasicCard
  def initialize
    @balance = 150.00
  end

  def card_number
    @card_number ||= generate_card_number 
  end
end