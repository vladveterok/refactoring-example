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