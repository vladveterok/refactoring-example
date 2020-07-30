module BankErrors
  class BankError < StandardError; end
  class NoMoneyError < BankError
    def message
      I18n.t(:no_money_error)
    end
  end

  class TaxTooHigh < BankError
    def message
      I18n.t(:tax_too_high)
    end
  end

  class WrongCardType < BankError
    def message
      I18n.t(:wrong_card_type)
    end
  end

  class NoActiveCard < BankError
    def message
      I18n.t(:no_active_card)
    end
  end
end
