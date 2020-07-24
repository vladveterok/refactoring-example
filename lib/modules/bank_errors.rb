module BankErrors
  class BankError < StandardError; end
  class NoMoneyError < BankError
    def message
      "You don't have enough money on card for such operation"
    end
  end
end
