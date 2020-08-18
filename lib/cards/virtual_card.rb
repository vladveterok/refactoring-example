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

  def balance
    @balance ||= 150.00
  end

  def type
    @type ||= 'virtual'
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
