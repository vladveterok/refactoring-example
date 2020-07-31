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

def create_the_first_account
  Creator.new.create_the_first_account
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