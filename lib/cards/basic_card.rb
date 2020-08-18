class BasicCard
  include BankErrors

  attr_reader :number
  attr_accessor :balance

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

  def initialize
    @number = generate_card_number
  end

  def withdraw_money(amount)
    money_left = balance - amount - withdraw_tax(amount)
    raise BankErrors::NoMoneyError unless money_left.positive?

    @balance = money_left
  end

  def put_money(amount)
    new_money_amount = balance + amount - put_tax(amount)
    raise BankErrors::TaxTooHigh if put_tax(amount) >= amount

    @balance = new_money_amount
  end

  def send_money(amount)
    money_left = balance - amount - sender_tax(amount)
    raise BankErrors::NoMoneyError if money_left.negative?

    @balance = money_left
  end

  private

  def tax(amount, percent, fixed)
    amount * percent / 100.0 + fixed
  end

  def generate_card_number
    Array.new(CARD_NUMBER_LENGTH) { rand(10) }.join
  end
end
