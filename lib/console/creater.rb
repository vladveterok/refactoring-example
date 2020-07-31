class Console
  module Creater
    def create_the_first_account
      puts I18n.t(:create_first_account)
      gets.chomp == 'y' ? create : console
    end
  
    def create
      ask_credentials
  
      account.create
      @current_account = account.current_account
      main_menu
    end
  end
end