class BasicCard
  include BankErrors

  attr_accessor :balance
  attr_reader :number
  CARD_NUMBER_LENGTH = 16

  TAX_PERCENT = {
    withdraw: 0,
    put: 0,
    sender: 0
  }.freeze

  TAX_FIXED = {
    withdraw: 0,
    put: 0,
    sender: 0
  }.freeze

  def balance!(amount)
    @balance = amount
  end

  def type
    @type ||= self.class.to_s[0...-4].downcase
  end

  def withdraw_money(amount)
    money_left = balance - amount - withdraw_tax(amount)
    raise BankErrors::NoMoneyError unless money_left.positive?

    balance!(money_left)
  end

  private

  def tax(amount, percent, fixed)
    amount * percent / 100.0 + fixed
  end

  def generate_card_number
    Array.new(CARD_NUMBER_LENGTH) { rand(10) }.join
  end
end
