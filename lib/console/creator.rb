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

  def return_errors
    @errors = account.errors
    @errors.select! { |error| puts error.message }
  end
end
