require 'yaml'
require 'pry'

class Account
  include FileLoader
  include MoneyOperations

  attr_accessor :login, :name, :age, :card, :password, :file_path, :current_account

  def initialize
    @file_path = 'accounts.yml'

    @name = nil
    @login = nil
    @age = 0
    @password = nil
    @card = []
    @current_account = nil
  end

  def create
    new_accounts = accounts << self
    @current_account = self
    save_in_file(new_accounts)
  end

  def load(login, password)
    if accounts.map { |a| { login: a.login, password: a.password } }.include?({ login: login, password: password })
      @current_account = accounts.select { |a| login == a.login }.first
    end
  end

  def create_card
    cards = @current_account.card # << card
    @current_account.card = cards #important!!!
    new_accounts = []
    accounts.each do |ac|
      if ac.login == @current_account.login
        new_accounts.push(@current_account)
      else
        new_accounts.push(ac)
      end
    end
    save_in_file(new_accounts)
  end

  def destroy_card(card_number)
    @current_account.card.delete_at(card_number - 1)
    new_accounts = []
    accounts.each do |ac|
      if ac.login == @current_account.login
        new_accounts.push(@current_account)
      else
        new_accounts.push(ac)
      end
    end
    save_in_file(new_accounts)
  end

  def destroy_account
    new_accounts = []
    accounts.each do |ac|
      if ac.login == @current_account.login
      else
        new_accounts.push(ac)
      end
    end
    save_in_file(new_accounts)
  end

  def accounts
    File.exist?('accounts.yml') ? YAML.load_file('accounts.yml') : []
  end

  private

  def save_in_file(data)
    File.open(@file_path, 'w') { |f| f.write data.to_yaml }
  end
end
