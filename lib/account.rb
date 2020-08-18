require 'yaml'
require 'pry'

class Account
  include BankErrors
  include Validation
  include FileLoader
  include MoneyOperations

  attr_reader :name, :age, :login, :password, :errors, :current_account, :card, :file_path

  FILE_PATH = 'accounts.yml'.freeze

  CARD_TYPES = {
    usual: UsualCard,
    capitalist: CapitalistCard,
    virtual: VirtualCard
  }.freeze

  LOGIN_LENGTH = (4..20).freeze
  PASSWORD_LENGTH = (6..30).freeze
  AGE_RANGE = (23..90).freeze

  def initialize
    @errors = []
    # @file_path = 'accounts.yml'
    @card = []
    @current_account = nil
  end

  def credentials(name:, age:, login:, password:)
    name_errors(name: name, errors: @errors)
    age_errors(age: age, errors: @errors, range: AGE_RANGE)
    login_errors(login: login, errors: @errors, length: LOGIN_LENGTH)
    password_errors(password: password, errors: @errors, length: PASSWORD_LENGTH)

    @name = name
    @age = age
    @login = login
    @password = password
  end

  def create
    new_accounts = accounts << @current_account = self
    save_in_file(new_accounts, FILE_PATH)
  end

  def load(login, password)
    @current_account = accounts.find { |a| login == a.login && password == a.password }

    raise_error(NoAccountError) if @current_account.nil?
  end

  def create_card(card_type)
    raise_error(WrongCardType) if CARD_TYPES[card_type.to_sym].nil?

    @current_account.card << CARD_TYPES[card_type.to_sym].new
    update_account
  end

  def destroy_card(card_number)
    raise_error(NoActiveCard) unless @current_account.card.any?

    @current_account.card.delete_at(card_number - 1)
    update_account
  end

  def destroy_account
    new_accounts = []
    accounts.each do |account|
      new_accounts.push(account) unless account.login == @current_account.login
    end
    save_in_file(new_accounts, FILE_PATH)
  end

  def accounts
    read_file(FILE_PATH)
  end

  private

  def login_exists?(login)
    accounts.map(&:login).include? login
  end

  def update_card(card)
    new_accounts = []
    accounts.each do |account|
      account.card.collect! { |stored_card| stored_card.number == card.number ? card : stored_card }
      new_accounts.push(account)
    end

    save_in_file(new_accounts, FILE_PATH)
  end

  def update_account
    new_accounts = []
    accounts.each do |account|
      account.login == @current_account.login ? new_accounts.push(@current_account) : new_accounts.push(account)
    end
    save_in_file(new_accounts, FILE_PATH)
  end
end
