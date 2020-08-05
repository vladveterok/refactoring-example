module Validation
  def validate_string
    # some code here
  end

  def name_errors(name, errors)
    return errors.push(BankErrors::NoNameError.new) if name == ''
    return errors.push(BankErrors::NoNameError.new) unless name.capitalize == name
  end

  def age_errors(age, errors)
    return errors.push(BankErrors::AgeError.new) unless age.is_a?(Integer)
    return errors.push(BankErrors::AgeError.new) if age.to_i < Account::AGE_RANGE.min
    return errors.push(BankErrors::AgeError.new) if age.to_i > Account::AGE_RANGE.max
  end

  def login_errors(login, errors)
    return errors.push(BankErrors::NoLoginError.new) if login == ''
    return errors.push(BankErrors::ShortLoginError.new) if login.length < Account::LOGIN_LENGTH.min
    return errors.push(BankErrors::LongLoginError.new) if login.length > Account::LOGIN_LENGTH.max
    return errors.push(BankErrors::AccountExists.new) if login_exists?(login)
  end

  def password_errors(password, errors)
    return errors.push(BankErrors::NoPasswordError.new) if password == ''
    return errors.push(BankErrors::ShortPasswordError.new) if password.length < Account::PASSWORD_LENGTH.min
    return errors.push(BankErrors::LongPasswordError.new) if password.length > Account::PASSWORD_LENGTH.max
  end

  def raise_error(error)
    # some code here
  end

  def collect_errors(error)
    # some code here
  end
end
