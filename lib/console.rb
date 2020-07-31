class Console
  include BankErrors
  include MoneyOperationsConsole

  # attr_accessor :current_account

  def initialize
    @errors = []
    @current_account = nil
    account
    # menu_commands
  end

  def account
    @account ||= Account.new
  end

  def console
    puts I18n.t(:console)

    case gets.chomp
    when 'create' then create
    when 'load' then load
    else exit
    end
    # main_menu
  rescue BankErrors::BankError => e
    puts e.message
    retry
  end

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

  def current_account
    @current_account ||= account.current_account
  end

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

  def main_menu
    loop do
      puts I18n.t(:menu, name: @current_account.name)

      command = gets.chomp
      break if command == 'exit'

      commands(command)
      # puts "Wrong command. Try again!\n" if commands(gets.chomp).nil? # (gets.chomp)
    end
  rescue BankErrors::BankError => e
    puts e.message
    retry
  end

  MENU_COMMANDS = {
    SC: :show_cards,
    CC: :create_card,
    DC: :destroy_card,
    PM: :put_money,
    WM: :withdraw_money,
    SM: :send_money,
    DA: :destroy_account
  }.freeze

  def commands(command)
    raise CommandError if MENU_COMMANDS[command.to_sym].nil?

    method(MENU_COMMANDS[command.to_sym]).call
=begin
    case command
    when 'SC' then show_cards
    when 'CC' then create_card
    when 'DC' then destroy_card
    when 'PM' then put_money
    when 'WM' then withdraw_money
    when 'SM' then send_money
    when 'DA' then destroy_account
    # else puts I18n.t(:wrong_command)
    else raise CommandError
    end
=end
  end

  def show_cards
    # return puts I18n.t(:no_active_card) if account.current_account.card.empty?
    raise NoActiveCard if @current_account.card.empty?

    @current_account.card.each { |card| puts "- #{card.number}, #{card.type}" }
  end

  def create_card
    loop do
      puts I18n.t(:create_card)
      card = gets.chomp

      exit if card == 'exit'
      account.create_card(card)
      break
    end
  end

  def destroy_card
    raise NoActiveCard unless current_account_cards.any?

    loop do
      puts I18n.t(:if_want_delete)
      show_cards_with_index
      puts I18n.t(:press_exit)

      break if (answer = gets.chomp) == 'exit'
      next puts I18n.t(:wrong_number) unless card_exists?(answer)

      puts I18n.t(:sure_to_delete_card, card: current_card(answer).number)
      account.destroy_card(answer.to_i) if gets.chomp == 'y'
      break
    end
  end

  def destroy_account
    puts I18n.t(:sure_to_destroy_acc)
    answer = gets.chomp
    account.destroy_account if answer == 'y'
  end

  private

  def ask_credentials
    loop do
      account.name = name_input
      account.age = age_input
      account.login = login_input
      account.password = password_input
      break if @errors.empty?

      return_errors
    end
  end

  def name_input
    puts I18n.t(:enter_name)
    name = gets.chomp
    return name if name != '' && name.capitalize == name

    @errors.push(I18n.t(:name_must_be))
  end

  def age_input
    puts I18n.t(:enter_age)
    age = gets.chomp
    return age.to_i if age.to_i.is_a?(Integer) && age.to_i >= 23 && age.to_i <= 90

    @errors.push(I18n.t(:age_must_be))
  end

  def login_input
    puts I18n.t(:enter_login)
    login = gets.chomp

    @errors.push(I18n.t(:login_must_be)) if login == ''
    @errors.push(I18n.t(:login_must_longer)) if login.length < 4
    @errors.push(I18n.t(:login_must_shorter)) if login.length > 20

    login_exists?(login) ? @errors.push(I18n.t(:account_exists)) : login
  end

  def login_exists?(login)
    account.accounts.map(&:login).include? login
  end

  #### MOVE errors into app?
  def password_input
    puts I18n.t(:enter_password)
    password = gets.chomp

    @errors.push(I18n.t(:password_must_be)) if password == ''
    @errors.push(I18n.t(:password_must_longer)) if password.length < 6
    @errors.push(I18n.t(:password_must_shorter)) if password.length > 30

    password
  end

  def choose_the_card(operation)
    # @current_account.card.any? ? (puts I18n.t(:choose_card, action: operation)) : (raise NoActiveCard)
    puts I18n.t(:choose_card, action: operation)
    show_cards_with_index

    puts I18n.t(:press_exit)
    answer_card = gets.chomp
    return answer_card if answer_card == 'exit'

    card_exists?(answer_card) ? answer_card : (raise WrongNumberError)
  end

  def card_exists?(answer_card)
    (1..@current_account.card.length).include? answer_card.to_i
  end

  def show_cards_with_index
    raise NoActiveCard if @current_account.card.empty?

    @current_account.card.each_with_index do |card, index|
      puts I18n.t(:show_card, num: card.number, type: card.type, index: index + 1)
    end
  end

  def accounts
    account.accounts
  end

  def current_card(number)
    @current_account.card[number.to_i - 1]
  end

  def current_account_cards
    @current_account.card
  end

  def return_errors
    @errors.each do |e|
      puts e
    end
    @errors = []
  end
end
