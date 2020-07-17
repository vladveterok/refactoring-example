class CapitalistCard < BasicCard
  def initialize
    @balance = 100.00
  end

  def card_number
    @card_number ||= generate_card_number 
  end
end