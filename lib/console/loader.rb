class Loader < Console
  def load
    return create_the_first_account unless accounts.any?

    puts I18n.t(:enter_login)
    login = gets.chomp
    puts I18n.t(:enter_password)
    password = gets.chomp

    load_account(login, password)
    main_menu
  end

  def load_account(login, password)
    account.load(login, password)
    current_account
  end
end
