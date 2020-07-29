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

  class WrongCardType < BankError
    def message
      'Wrong card type. Try again!'
    end
  end

  class NoActiveCard < BankError
    def message
      'There is no active cards!\n'
    end
  end
end
