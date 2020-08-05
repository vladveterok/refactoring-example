class Creator < Console
  def create
    ask_credentials

    account.create
    current_account
    main_menu
  end

  def create_the_first_account
    puts I18n.t(:create_first_account)
    gets.chomp == 'y' ? create : console
  end

  private

  def ask_credentials
    loop do
      account.credentials(name: name, age: age, login: login, password: password)
      # name
      # age
      # login
      # password
      break if account.errors.empty?

      return_errors
    end
  end

  def name
    puts I18n.t(:enter_name)
    gets.chomp
    # account.name!(gets.chomp)
  end

  def age
    puts I18n.t(:enter_age)
    gets.chomp.to_i
    # account.age!(gets.chomp.to_i)
  end

  def login
    puts I18n.t(:enter_login)
    gets.chomp
    # account.login!(gets.chomp)
  end

  def password
    puts I18n.t(:enter_password)
    gets.chomp
    # account.password!(gets.chomp)
  end

  def return_errors
    @errors = account.errors
    @errors.select! { |error| puts error.message }
  end
end
