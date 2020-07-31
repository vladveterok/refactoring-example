class CardHandler < Console
  def initialize
  end

  def create_card
    current_account
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
end

=begin
class Console
  # Card methods for choosing, showing cards, and check whether choosen card exists
  module CardPicker
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
  end
end
=end