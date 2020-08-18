module Validation
  def name_errors(name:, errors:)
    return collect_errors(BankErrors::NoNameError.new, errors) if name.empty?
    return collect_errors(BankErrors::NoNameError.new, errors) unless name.capitalize == name
  end

  def age_errors(age:, errors:, range:)
    return collect_errors(BankErrors::AgeError.new, errors) unless age.is_a?(Integer)
    return collect_errors(BankErrors::AgeError.new, errors) unless range.include?(age.to_i)
  end

  def login_errors(login:, errors:, length:)
    return collect_errors(BankErrors::NoLoginError.new, errors) if login == ''
    return collect_errors(BankErrors::ShortLoginError.new, errors) if login.length < length.min
    return collect_errors(BankErrors::LongLoginError.new, errors) if login.length > length.max
    return collect_errors(BankErrors::AccountExists.new, errors) if login_exists?(login)
  end

  def password_errors(password:, errors:, length:)
    return collect_errors(BankErrors::NoPasswordError.new, errors) if password.empty?
    return collect_errors(BankErrors::ShortPasswordError.new, errors) if password.length < length.min
    return collect_errors(BankErrors::LongPasswordError.new, errors) if password.length > length.max
  end

  def raise_error(error)
    raise error
  end

  def collect_errors(error, errors)
    errors.push(error)
  end
end
