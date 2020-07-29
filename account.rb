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
  # binding.pry
    # @current_account = accounts.select { |a| login == a.login && password == a.password }.first
    @current_account = accounts.find { |a| login == a.login && password == a.password }
  end

  def create_card
    cards = @current_account.card
    @current_account.card = cards
    update_account
  end

  def destroy_card(card_number)
    @current_account.card.delete_at(card_number - 1)
    update_account
  end

  def destroy_account
    new_accounts = []
    accounts.each do |account|
      new_accounts.push(account) unless account.login == @current_account.login
    end
    save_in_file(new_accounts)
  end

  def accounts
    File.exist?('accounts.yml') ? YAML.load_file('accounts.yml') : []
  end

  private

  def update_account
    new_accounts = []
    accounts.each do |account|
      account.login == @current_account.login ? new_accounts.push(@current_account) : new_accounts.push(account)
    end
    save_in_file(new_accounts)
  end

  def save_in_file(data)
    File.open(@file_path, 'w') { |f| f.write data.to_yaml }
  end
end
