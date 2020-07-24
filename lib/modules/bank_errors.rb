module BankErrors
  class BankError < StandardError; end
  class NoMoneyError < BankError
    def message
      "You don't have enough money on card for such operation"
    end
  end

  class TaxTooHigh < BankError
    def message
      'Your tax is higher than input amount'
    end
  end
end
