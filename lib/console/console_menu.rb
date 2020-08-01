class ConsoleMenu < Console
  def initialize(current_account)
    @current_account = current_account
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

  def main_menu
    loop do
      puts I18n.t(:menu, name: current_account.name)

      command = gets.chomp
      break if command == 'exit'

      commands(command)
    end
  rescue BankErrors::BankError => e
    puts e.message
    retry
  end

  def commands(command)
    raise CommandError if MENU_COMMANDS[command.to_sym].nil?

    method(MENU_COMMANDS[command.to_sym]).call
  end
end
