class Loader < Console
  def load
    return create_the_first_account unless accounts.any?

    puts I18n.t(:enter_login)
    login = gets.chomp
    puts I18n.t(:enter_password)
    password = gets.chomp

    account.load(login, password)
    current_account
    main_menu
  end
end
=begin
class Console
  module Loader
    def load
      return create_the_first_account unless accounts.any?
  
      puts I18n.t(:enter_login)
      login = gets.chomp
      puts I18n.t(:enter_password)
      password = gets.chomp
  
      account.load(login, password)
      current_account
      main_menu
    end
  end
end
=end