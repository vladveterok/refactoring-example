class Console
  include BankErrors
  # include Console::CardPicker
  include Console::MoneyOperationsConsole
=begin
  MENU_COMMANDS = {
    SC: :show_cards,
    CC: :create_card,
    DC: :destroy_card,
    PM: :put_money,
    WM: :withdraw_money,
    SM: :send_money,
    DA: :destroy_account
  }.freeze
=end

  def initialize
    @errors = []
    # @current_account = nil
    # @card_handler = CardHandler.new
    account
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

  #### SPLIT LOGIC
  def load
    Loader.new.load
  end

  #### SPLIT LOGIC
  def create
    Creator.new.create
  end

  #### SPLIT LOGIC
  def create_the_first_account
    Creator.new.create_the_first_account
  end

  def current_account
    @current_account ||= account.current_account
  end

  #### SPLIT LOGIC
  def main_menu
    @main_menu ||= ConsoleMenu.new(current_account)
    @main_menu.main_menu
  end

=begin
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

  def commands(command)
    raise CommandError if MENU_COMMANDS[command.to_sym].nil?

    method(MENU_COMMANDS[command.to_sym]).call
  end
=end

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
      # account.create_card(card)
      # binding.pry
      current_account.create_card(card)
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
      current_account.destroy_card(answer.to_i) if gets.chomp == 'y'
      break
    end
  end

  def destroy_account
    puts I18n.t(:sure_to_destroy_acc)
    answer = gets.chomp
    account.destroy_account if answer == 'y'
  end

  private

  def choose_the_card(operation)
    # @current_account.card.any? ? (puts I18n.t(:choose_card, action: operation)) : (raise NoActiveCard)
    puts I18n.t(:choose_card, action: operation)
    show_cards_with_index

    puts I18n.t(:press_exit)
    answer_card = gets.chomp
    return answer_card if answer_card == 'exit'

    card_exists?(answer_card) ? answer_card : (raise BankErrors::WrongNumberError)
  end

  def show_cards_with_index
    raise BankErrors::NoActiveCard if @current_account.card.empty?

    @current_account.card.each_with_index do |card, index|
      puts I18n.t(:show_card, num: card.number, type: card.type, index: index + 1)
    end
  end

  def current_card(number)
    @current_account.card[number.to_i - 1]
  end

  def current_account_cards
    @current_account.card
  end

  def card_exists?(answer_card)
    (1..@current_account.card.length).include? answer_card.to_i
  end

  def login_exists?(login)
    account.accounts.map(&:login).include? login
  end

  def accounts
    account.accounts
  end

  def return_errors
    @errors.each do |e|
      puts e
    end
    @errors = []
  end
end
