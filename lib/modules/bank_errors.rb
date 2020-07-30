module BankErrors
  class BankError < StandardError; end
  # class ConsoleError < StandardError; end

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

class NoAccountError < BankError
  def message
    I18n.t(:no_such_account)
  end
end

  class NoNameError < BankError # ConsoleError
    def message
      I18n.t(:name_must_be)
    end
  end

  class AgeError < BankError # ConsoleError
    def message
      I18n.t(:age_must_be)
    end
  end

  class LoginError < BankError; end # ConsoleError; end
  class NoLoginError < LoginError
    def message
      I18n.t(:login_must_be)
    end
  end

  class ShortLoginError < LoginError
    def message
      I18n.t(:login_must_longer)
    end
  end

  class LongLoginError < LoginError
    def message
      I18n.t(:login_must_shorter)
    end
  end

  class PasswordError < BankError;end # ConsoleError; end
  class NoPasswordError < PasswordError
    def message
      I18n.t(:password_must_be)
    end
  end

  class ShortPasswordError < PasswordError
    def message
      I18n.t(:password_must_longer)
    end
  end

  class LongPasswordError < PasswordError
    def message
      I18n.t(:password_must_shorter)
    end
  end

  class CommandError < BankError
    def message
      I18n.t(:wrong_command)
    end
  end

  # class WrongNUmberError < BankError
  #  def message
  #    I18n.t(:wrong_number)
  #  end
  # end
end
