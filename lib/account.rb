require 'yaml'
require 'pry'

class Account
  include BankErrors
  include Validation
  include FileLoader
  include MoneyOperations

  attr_accessor :file_path
  attr_reader :name, :age, :login, :password, :errors, :current_account, :card

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
    @file_path = 'accounts.yml'

    @name = nil
    @login = nil
    @age = 0
    @password = nil
    @card = []
    @current_account = nil
  end

  def name!(name)
    name_errors(name: name, errors: @errors)

    @name = name
  end

  def age!(age)
    age_errors(age: age, errors: @errors, range: AGE_RANGE)

    @age = age
  end

  def login!(login)
    login_errors(login: login, errors: @errors, length: LOGIN_LENGTH)

    @login = login
  end

  def password!(password)
    password_errors(password: password, errors: @errors, length: PASSWORD_LENGTH)

    @password = password
  end

  def create
    new_accounts = accounts << @current_account = self
    save_in_file(new_accounts)
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
    save_in_file(new_accounts)
  end

  # def accounts
  #  File.exist?('accounts.yml') ? YAML.load_file('accounts.yml') : []
  # end

  private

  def login_exists?(login)
    accounts.map(&:login).include? login
  end

  # def update_account
  #  new_accounts = []
  #  accounts.each do |account|
  #    account.login == @current_account.login ? new_accounts.push(@current_account) : new_accounts.push(account)
  #  end
  #  save_in_file(new_accounts)
  # end

  # def save_in_file(data)
  #  File.open(@file_path, 'w') { |f| f.write data.to_yaml }
  # end
end
