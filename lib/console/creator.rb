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
    loop do
      account.name = name_input
      account.age = age_input
      account.login = login_input
      account.password = password_input
      break if @errors.empty?

      return_errors
    end
  end

  def name_input
    puts I18n.t(:enter_name)
    name = gets.chomp
    return name if name != '' && name.capitalize == name

    @errors.push(I18n.t(:name_must_be))
  end

  def age_input
    puts I18n.t(:enter_age)
    age = gets.chomp
    return age.to_i if age.to_i.is_a?(Integer) && age.to_i >= 23 && age.to_i <= 90

    @errors.push(I18n.t(:age_must_be))
  end

  def login_input
    puts I18n.t(:enter_login)
    login = gets.chomp

    @errors.push(I18n.t(:login_must_be)) if login == ''
    @errors.push(I18n.t(:login_must_longer)) if login.length < 4
    @errors.push(I18n.t(:login_must_shorter)) if login.length > 20

    login_exists?(login) ? @errors.push(I18n.t(:account_exists)) : login
  end

  def password_input
    puts I18n.t(:enter_password)
    password = gets.chomp

    @errors.push(I18n.t(:password_must_be)) if password == ''
    @errors.push(I18n.t(:password_must_longer)) if password.length < 6
    @errors.push(I18n.t(:password_must_shorter)) if password.length > 30

    password
  end
end

=begin
class Console
  module Creator
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

    def ask_credentials
      loop do
        account.name = name_input
        account.age = age_input
        account.login = login_input
        account.password = password_input
        break if @errors.empty?

        return_errors
      end
    end

    def name_input
      puts I18n.t(:enter_name)
      name = gets.chomp
      return name if name != '' && name.capitalize == name

      @errors.push(I18n.t(:name_must_be))
    end

    def age_input
      puts I18n.t(:enter_age)
      age = gets.chomp
      return age.to_i if age.to_i.is_a?(Integer) && age.to_i >= 23 && age.to_i <= 90

      @errors.push(I18n.t(:age_must_be))
    end

    def login_input
      puts I18n.t(:enter_login)
      login = gets.chomp

      @errors.push(I18n.t(:login_must_be)) if login == ''
      @errors.push(I18n.t(:login_must_longer)) if login.length < 4
      @errors.push(I18n.t(:login_must_shorter)) if login.length > 20

      login_exists?(login) ? @errors.push(I18n.t(:account_exists)) : login
    end

    def password_input
      puts I18n.t(:enter_password)
      password = gets.chomp

      @errors.push(I18n.t(:password_must_be)) if password == ''
      @errors.push(I18n.t(:password_must_longer)) if password.length < 6
      @errors.push(I18n.t(:password_must_shorter)) if password.length > 30

      password
    end
  end
end
=end