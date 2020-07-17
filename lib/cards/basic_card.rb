class BasicCard

  CARD_NUMBER_LENGTH = 16

  def card_number
    @card_number ||= CARD_NUMBER_LENGTH.times.map { rand(10) }.join
  end
end