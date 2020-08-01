require 'yaml'
require 'pry'

class Account
  include BankErrors
  include FileLoader
  include MoneyOperations

  attr_accessor :card, :file_path #:name
  attr_reader :name, :age, :login, :password, :errors, :current_account

  CARD_TYPES = {
    usual: UsualCard,
    capitalist: CapitalistCard,
    virtual: VirtualCard
  }.freeze

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
    return @errors.push(NoNameError.new) unless name != '' && name.capitalize == name

    @name = name
  end

  def age!(age)
    return @errors.push(AgeError.new) unless age.is_a?(Integer) && age.to_i >= 23 && age.to_i <= 90

    @age = age
  end

  def login!(login)
    @errors.push(NoLoginError.new) if login == ''
    @errors.push(ShortLoginError.new) if login.length < 4
    @errors.push(LongLoginError.new) if login.length > 20
    @errors.push(AccountExists.new) if login_exists?(login)

    @login = login
  end

  def password!(password)
    @errors.push(NoPasswordError.new) if password == ''
    @errors.push(ShortPasswordError.new) if password.length < 6
    @errors.push(LongPasswordError.new) if password.length > 30

    @password = password
  end

  def create
    # return_errors unless @errors.empty?

    new_accounts = accounts << @current_account = self
    save_in_file(new_accounts)
  end

  def load(login, password)
    @current_account = accounts.find { |a| login == a.login && password == a.password }

    raise NoAccountError if @current_account.nil?
  end

  def create_card(card_type)
    raise WrongCardType if CARD_TYPES[card_type.to_sym].nil?

    @current_account.card << CARD_TYPES[card_type.to_sym].new
    update_account
  end

  def destroy_card(card_number)
    raise NoActiveCard unless @current_account.card.any?

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

  # def return_errors
  #  @errors.select! { |error| raise error }
  # end

  private

  def login_exists?(login)
    accounts.map(&:login).include? login
  end

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
