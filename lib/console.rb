class Console
  include BankErrors
  include MoneyOperationsConsole

  attr_reader :errors

  def initialize
    @errors = []
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
  rescue BankErrors::BankError => e
    puts e.message
    retry
  end

  def load
    Loader.new.load
  end

  def create
    Creator.new.create
  end

  def create_the_first_account
    Creator.new.create_the_first_account
  end

  def current_account
    @current_account ||= account.current_account
  end

  def main_menu
    @main_menu ||= ConsoleMenu.new(current_account)
    @main_menu.main_menu
  end

  def show_cards
    raise NoActiveCard if current_account_cards.empty?

    current_account_cards.each { |card| puts "- #{card.number}, #{card.type}" }
  end

  def create_card
    loop do
      puts I18n.t(:create_card)
      card = gets.chomp

      exit if card == 'exit'
      current_account.create_card(card)
      break
    end
  end

  def destroy_card
    return if (answer = choose_the_card('delete')) == 'exit'

    puts I18n.t(:sure_to_delete_card, card: current_card(answer).number)
    current_account.destroy_card(answer.to_i) if gets.chomp == 'y'
  rescue BankErrors::WrongNumberError => e
    puts e.message
    retry
  end

  def destroy_account
    puts I18n.t(:sure_to_destroy_acc)
    answer = gets.chomp
    current_account.destroy_account if answer == 'y'
    exit if answer == 'y'
  end

  def withdraw_money
    # Transactions.new(current_account).withdraw_money
    withdrawal(@current_account)
  end

  def put_money
    # Transactions.new(current_account).put_money
    putting(@current_account)
  end

  def send_money
    # Transactions.new(current_account).send_money
    sending(@current_account)
  end

  private

  def choose_the_card(operation)
    operation == 'delete' ? (puts I18n.t(:if_want_delete)) : (puts I18n.t(:choose_card, action: operation))
    show_cards_with_index

    puts I18n.t(:press_exit)
    answer_card = gets.chomp
    return answer_card if answer_card == 'exit'

    card_exists?(answer_card) ? answer_card : (raise BankErrors::WrongNumberError)
  end

  def show_cards_with_index
    raise BankErrors::NoActiveCard if current_account_cards.empty?

    current_account_cards.each_with_index do |card, index|
      puts I18n.t(:show_card, num: card.number, type: card.type, index: index + 1)
    end
  end

  def current_card(number)
    current_account_cards[number.to_i - 1]
  end

  def current_account_cards
    @current_account.card
  end

  def card_exists?(card_number)
    (1..current_account_cards.length).cover? card_number.to_i
  end

  def accounts
    account.accounts
  end
end
