class Creator < Console
  def create
    ask_credentials

    account.create
    @current_account = account.current_account
    main_menu
  end

  def create_the_first_account
    puts I18n.t(:create_first_account)
    gets.chomp == 'y' ? create : console
  end

  private

  def ask_credentials
=begin
    loop do
      account.name!(name_input)
      # account.name = name_input
      account.age!(age_input)
      # account.age = age_input
      account.login!(login_input)
      # account.login = login_input
      account.password!(password_input)
      # account.password = password_input
      break if account.errors.empty?

      return_errors
    end
=end
    loop do
      name
      age
      login
      password
      break if account.errors.empty?

      return_errors
    end
  end

  def name
    puts I18n.t(:enter_name)
    account.name!(gets.chomp)
  end

  def age
    puts I18n.t(:enter_age)
    account.age!(gets.chomp.to_i)
  end

  def login
    puts I18n.t(:enter_login)
    account.login!(gets.chomp)
  end

  def password
    puts I18n.t(:enter_password)
    account.password!(gets.chomp)
  end

=begin
  def name_input
    puts I18n.t(:enter_name)
    gets.chomp

    # return name if name != '' && name.capitalize == name

    # @errors.push(I18n.t(:name_must_be))
    # @errors.push(NoNameError.new)
  end

  def age_input
    puts I18n.t(:enter_age)
    gets.chomp.to_i

    #return age.to_i if age.to_i.is_a?(Integer) && age.to_i >= 23 && age.to_i <= 90

    # @errors.push(I18n.t(:age_must_be))
    # @errors.push(AgeError.new)
  end

  def login_input
    puts I18n.t(:enter_login)
    gets.chomp

    # login = gets.chomp

    # @errors.push(I18n.t(:login_must_be)) if login == ''
    # @errors.push(I18n.t(:login_must_longer)) if login.length < 4
    # @errors.push(I18n.t(:login_must_shorter)) if login.length > 20

    # account.login_exists?(login) ? @errors.push(I18n.t(:account_exists)) : login

    # @errors.push(NoLoginError.new) if login == ''
    # @errors.push(ShortLoginError.new) if login.length < 4
    # @errors.push(LongLoginError.new) if login.length > 20

    # account.login_exists?(login) ? @errors.push(AccountExists.new) : login
  end

  def password_input
    puts I18n.t(:enter_password)
    gets.chomp

    #password = gets.chomp

    # @errors.push(I18n.t(:password_must_be)) if password == ''
    # @errors.push(I18n.t(:password_must_longer)) if password.length < 6
    # @errors.push(I18n.t(:password_must_shorter)) if password.length > 30

    # @errors.push(NoPasswordError.new) if password == ''
    # @errors.push(ShortPasswordError.new) if password.length < 6
    # @errors.push(LongPasswordError.new) if password.length > 30

    # password
  end
=end
end
