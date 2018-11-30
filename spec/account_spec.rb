RSpec.describe Account do
  OVERRIDABLE_FILENAME = 'spec/fixtures/account.yml'.freeze

  COMMON_PHRASES = {
    create_first_account: "There is no active accounts, do you want to be the first?[y/n]\n",
    destroy_account: "Are you sure you want to destroy account?[y/n]\n",
    if_you_want_to_delete: "If you want to delete:"
  }.freeze

  HELLO_PHRASES = [
    'Hello, we are RubyG bank!',
    '- If you want to create account - press `create`',
    '- If you want to load account - press `load`',
    '- If you want to exit - press `exit`',
  ].freeze

  ASK_PHRASES = {
    name: 'Enter your name',
    login: 'Enter your login',
    password: 'Enter your password',
    age: 'Enter your age'
  }.freeze

  CREATE_CARD_PHRASES = [
    'You could create one of 3 card types',
    '- Usual card. 2% tax on card INCOME. 20$ tax on SENDING money from this card. 5% tax on WITHDRAWING money. For creation this card - press `usual`',
    '- Capitalist card. 10$ tax on card INCOME. 10% tax on SENDING money from this card. 4$ tax on WITHDRAWING money. For creation this card - press `capitalist`',
    '- Virtual card. 1$ tax on card INCOME. 1$ tax on SENDING money from this card. 12% tax on WITHDRAWING money. For creation this card - press `virtual`',
    '- For exit - press `exit`'
  ].freeze

  ACCOUNT_VALIDATION_PHRASES = {
    name: {
      first_letter: 'Your name must not be empty and starts with first upcase letter'
    },
    login: {
      present: 'Login must present',
      longer: 'Login must be longer then 4 symbols',
      shorter: 'Login must be shorter then 20 symbols',
      exists: 'Such account is already exists',
    },
    password: {
      present: 'Password must present',
      longer: 'Password must be longer then 6 symbols',
      shorter: 'Password must be shorter then 30 symbols'
    },
    age: {
      length: 'Your Age must be greeter then 23 and lower then 90'
    }
  }.freeze

  ERROR_PHRASES = {
    user_not_exists: 'There is no account with given credentials',
    wrong_command: 'Wrong command. Try again!',
    no_active_cards: "There is no active cards!\n",
    wrong_card_type: "Wrong card type. Try again!\n",
    wrong_number: "You entered wrong number!\n"
  }.freeze

  MAIN_OPERATIONS_TEXTS = [
    'If you want to:',
    '- show all cards - press SC',
    '- create card - press CC',
    '- destroy card - press DC',
    '- put money on card - press PM',
    '- withdraw money on card - press WM',
    '- send money to another card  - press SM',
    '- destroy account - press `DA`',
    '- exit from account - press `exit`'
  ].freeze

  CARDS = {
    usual: {
      type: 'usual',
      balance: 50.00
    },
    capitalist: {
      type: 'capitalist',
      balance: 100.00
    },
    virtual: {
      type: 'virtual',
      balance: 150.00
    }
  }.freeze

  let(:subject) { described_class.new }

  describe "#console" do
    context 'correct method calling' do
      after do
        subject.console
      end

      it 'returns create if input is create' do
        allow(subject).to receive_message_chain(:gets, :chomp) { 'create' }
        expect(subject).to receive(:create)
      end

      it 'returns create if input is create' do
        allow(subject).to receive_message_chain(:gets, :chomp) { 'load' }
        expect(subject).to receive(:load)
      end


      it 'returns create if input is exit or some another word' do
        allow(subject).to receive_message_chain(:gets, :chomp) { 'another' }
        expect(subject).to receive(:exit)
      end
    end

    context 'output' do
      it do
        allow(subject).to receive_message_chain(:gets, :chomp) { 'test' }
        allow(subject).to receive(:exit)
        HELLO_PHRASES.each { |phrase| expect(subject).to receive(:puts).with(phrase) }
        subject.console
      end
    end
  end

  describe '#create' do
    let(:success_name_input) { 'Denis' }
    let(:success_age_input) { '72' }
    let(:success_login_input) { 'Denis' }
    let(:success_password_input) { 'Denis1993' }
    let(:success_inputs) { [success_name_input, success_age_input, success_login_input, success_password_input] }

    context 'success result' do
      before do
        allow(subject).to receive_message_chain(:gets, :chomp).and_return(*success_inputs)
        allow(subject).to receive(:main_menu)
        allow(subject).to receive(:accounts) { [] }
      end

      after do
        File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
      end

      it 'output' do
        allow(File).to receive(:open)
        ASK_PHRASES.values.each { |phrase| expect(subject).to receive(:puts).with(phrase) }
        ACCOUNT_VALIDATION_PHRASES.values.map(&:values).each { |phrase| expect(subject).not_to receive(:puts).with(phrase) }
        subject.create
      end

      it 'write to file Account instance' do
        subject.instance_variable_set(:@file_path, OVERRIDABLE_FILENAME)
        subject.create
        expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
        accounts = YAML.load_file(OVERRIDABLE_FILENAME)
        expect(accounts).to be_a Array
        expect(accounts.size).to be 1
        accounts.map { |account| expect(account).to be_a Account }
      end
    end

    context 'errors' do
      before do
        all_inputs = current_inputs + success_inputs
        allow(File).to receive(:open)
        allow(subject).to receive_message_chain(:gets, :chomp).and_return(*all_inputs)
        allow(subject).to receive(:main_menu)
        allow(subject).to receive(:accounts) { [] }
      end

      after do
        expect { subject.create }.to output(/#{error}/).to_stdout
      end

      context 'name errors' do
        context 'without small letter' do
          let(:error_input) { 'some_test_name' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:name][:first_letter] }
          let(:current_inputs) { [error_input, success_age_input, success_login_input, success_password_input] }

          it {}
        end
      end

      context 'login errors' do
        let(:current_inputs) { [success_name_input, success_age_input, error_input, success_password_input] }

        context 'present' do
          let(:error_input) { '' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:present] }
          it {}
        end

        context 'longer' do
          let(:error_input) { 'E' * 3 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:longer] }
          it {}
        end

        context 'shorter' do
          let(:error_input) { 'E' * 21 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:shorter] }
          it {}
        end

        context 'exists' do
          let(:error_input) { 'Denis1345' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:exists] }

          before do
            allow(subject).to receive(:accounts) { [double('Account', login: error_input)] }
          end

          it {}
        end
      end

      context 'age errors' do
        let(:current_inputs) { [success_name_input, error_input, success_login_input, success_password_input] }
        let(:error) { ACCOUNT_VALIDATION_PHRASES[:age][:length] }

        context 'length minimum' do
          let(:error_input) { '22' }
          it {}
        end

        context 'length maximum' do
          let(:error_input) { '91' }
          it {}
        end
      end

      context 'password errors' do
        let(:current_inputs) { [success_name_input, success_age_input, success_login_input, error_input] }

        context 'present' do
          let(:error_input) { '' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:password][:present] }
          it {}
        end

        context 'longer' do
          let(:error_input) { 'E' * 5 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:password][:longer] }
          it {}
        end

        context 'shorter' do
          let(:error_input) { 'E' * 31 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:password][:shorter] }
          it {}
        end
      end
    end
  end

  describe '#load' do
    context 'no active accounts' do
      it do
        expect(subject).to receive(:accounts) { [] }
        expect(subject).to receive(:create_the_first_account) { [] }
        subject.load
      end
    end

    context 'with active accounts' do
      let(:login) { 'Johnny' }
      let(:password) { 'johnny1' }

      before do
        allow(subject).to receive_message_chain(:gets, :chomp).and_return(*all_inputs)
        allow(subject).to receive(:accounts) { [double('Account', login: login, password: password)] }
        expect(subject).to receive(:main_menu)
      end

      context 'output' do
        let(:all_inputs) { [login, password] }

        it do
          [ASK_PHRASES[:login], ASK_PHRASES[:password]].each { |phrase| expect(subject).to receive(:puts).with(phrase) }
          subject.load
        end
      end

      context 'account exists' do
        let(:all_inputs) { [login, password] }

        it do
          expect { subject.load }.not_to output(/#{ERROR_PHRASES[:user_not_exists]}/).to_stdout
        end
      end

      context 'doesn\t account exists' do
        let(:all_inputs) { ['test', 'test', login, password] }

        it do
          expect { subject.load }.to output(/#{ERROR_PHRASES[:user_not_exists]}/).to_stdout
        end
      end
    end
  end

  describe '#create_the_first_account' do
    let(:cancel_input) { 'sdfsdfs' }
    let(:success_input) { 'y' }

    it 'output' do
      expect(subject).to receive_message_chain(:gets, :chomp) {  }
      expect(subject).to receive(:console)
      expect { subject.create_the_first_account }.to output(COMMON_PHRASES[:create_first_account]).to_stdout
    end

    it 'calls create if user inputs is y' do
      expect(subject).to receive_message_chain(:gets, :chomp) { success_input }
      expect(subject).to receive(:create)
      subject.create_the_first_account
    end

    it 'calls console if user inputs is not y' do
      expect(subject).to receive_message_chain(:gets, :chomp) { cancel_input }
      expect(subject).to receive(:console)
      subject.create_the_first_account
    end
  end

  describe '#main_menu' do
    let(:name) { 'John' }
    let(:commands) {
      {
        'SC' => :show_cards,
        'CC' => :create_card,
        'DC' => :destroy_card,
        'PM' => :put_money,
        'WM' => :withdraw_money,
        'SM' => :send_money,
        'DA' => :destroy_account,
        'exit' => :exit
      }
    }

    context 'output' do
      it do
        allow(subject).to receive(:show_cards)
        allow(subject).to receive(:exit)
        allow(subject).to receive_message_chain(:gets, :chomp).and_return('SC', 'exit')
        subject.instance_variable_set(:@current_account, double('Account', name: name))
        expect { subject.main_menu }.to output(/Welcome, #{name}/).to_stdout
        MAIN_OPERATIONS_TEXTS.each do |text|
          allow(subject).to receive_message_chain(:gets, :chomp).and_return('SC', 'exit')
          expect { subject.main_menu }.to output(/#{text}/).to_stdout
        end
      end
    end

    context 'commands' do
      let(:undefined_command) { 'undefined' }

      it 'calls specific methods on predefined commands' do
        subject.instance_variable_set(:@current_account, double('Account', name: name))
        allow(subject).to receive(:exit)

        commands.each do |command, method_name|
          expect(subject).to receive(method_name)
          allow(subject).to receive_message_chain(:gets, :chomp).and_return(command, 'exit')
          subject.main_menu
        end
      end

      it 'outputs incorrect message on undefined command' do
        subject.instance_variable_set(:@current_account, double('Account', name: name))
        expect(subject).to receive(:exit)
        allow(subject).to receive_message_chain(:gets, :chomp).and_return(undefined_command, 'exit')
        expect { subject.main_menu }.to output(/#{ERROR_PHRASES[:wrong_command]}/).to_stdout
      end
    end
  end

  describe '#destroy_account' do
    let(:cancel_input) { 'sdfsdfs' }
    let(:success_input) { 'y' }
    let(:correct_login) { 'test' }
    let(:fake_login) { 'test1' }
    let(:fake_login2) { 'test2' }
    let(:accounts) { [double('Account', login: correct_login), double('Account', login: fake_login), double('Account', login: fake_login2)] }

    after do
      File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
    end

    it 'output' do
      expect(subject).to receive_message_chain(:gets, :chomp) {  }
      expect { subject.destroy_account }.to output(COMMON_PHRASES[:destroy_account]).to_stdout
    end

    context 'deleting' do
      it 'delets account if user inputs is y' do
        expect(subject).to receive_message_chain(:gets, :chomp) { success_input }
        expect(subject).to receive(:accounts) { accounts }
        subject.instance_variable_set(:@file_path, OVERRIDABLE_FILENAME)
        subject.instance_variable_set(:@current_account, double('Account', login: correct_login))

        subject.destroy_account

        expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
        file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
        expect(file_accounts).to be_a Array
        expect(file_accounts.size).to be 2
      end

      it 'doesnt delete account' do
        expect(subject).to receive_message_chain(:gets, :chomp) { cancel_input }

        subject.destroy_account

        expect(File.exist?(OVERRIDABLE_FILENAME)).to be false
      end
    end
  end

  describe '#show_cards' do
    let(:cards) { [{ number: 1234, type: 'a' }, { number: 5678, type: 'b' }] }

    it 'display cards if there are any' do
      subject.instance_variable_set(:@current_account, double('Account', card: cards))
      cards.each { |card| expect(subject).to receive(:puts).with("- #{card[:number]}, #{card[:type]}") }
      subject.show_cards
    end

    it 'outputs error if there are no active cards' do
      subject.instance_variable_set(:@current_account, double('Account', card: []))
      expect(subject).to receive(:puts).with(ERROR_PHRASES[:no_active_cards])
      subject.show_cards
    end
  end

  describe '#create_card' do
    context 'output' do
      it do
        CREATE_CARD_PHRASES.each { |phrase| expect(subject).to receive(:puts).with(phrase) }
        subject.instance_variable_set(:@current_account, double('Account', card: [], 'card=' => 'some_card'))
        allow(subject).to receive(:accounts) { [] }
        allow(File).to receive(:open)
        expect(subject).to receive_message_chain(:gets, :chomp) { 'usual' }

        subject.create_card
      end
    end

    context 'correct card choose' do
      before do
        allow(subject).to receive(:card) { [] }
        allow(subject).to receive(:accounts) { [subject] }
        subject.instance_variable_set(:@file_path, OVERRIDABLE_FILENAME)
        subject.instance_variable_set(:@current_account, subject)
      end

      after do
        File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
      end

      CARDS.each do |card_type, card_info|
        it "create card with #{card_type} type" do
          expect(subject).to receive_message_chain(:gets, :chomp) { card_info[:type] }

          subject.create_card

          expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
          file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
          expect(file_accounts.first.card.first[:type]).to eq card_info[:type]
          expect(file_accounts.first.card.first[:balance]).to eq card_info[:balance]
          expect(file_accounts.first.card.first[:number].length).to be 16
        end
      end
    end

    context 'incorrect card choose' do
      it do
        subject.instance_variable_set(:@current_account, double('Account', card: [], 'card=' => 'some_card'))
        allow(File).to receive(:open)
        allow(subject).to receive(:accounts) { [] }
        allow(subject).to receive_message_chain(:gets, :chomp).and_return('test', 'usual')

        expect { subject.create_card }.to output(/#{ERROR_PHRASES[:wrong_card_type]}/).to_stdout
      end
    end
  end

  describe '#destroy_card' do
    context 'without cards' do
      it 'shows message about not active cards' do
        subject.instance_variable_set(:@current_account, double('Account', card: []))
        expect { subject.destroy_card }.to output(/#{ERROR_PHRASES[:no_active_cards]}/).to_stdout
      end
    end

    context 'has cards' do
        let(:fake_cards) { [{ number: 1, type: 'test' }, { number: 2, type: 'test2'}] }

      context 'output' do
        it do
          allow(subject).to receive(:card) { fake_cards }
          subject.instance_variable_set(:@current_account, subject)
          allow(subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect { subject.destroy_card }.to output(/#{COMMON_PHRASES[:if_you_want_to_delete]}/).to_stdout
          fake_cards.each_with_index do |card, i|
            expect { subject.destroy_card }.to output(/- #{card[:number]}, #{card[:type]}, press #{i + 1}/).to_stdout
          end
          subject.destroy_card
        end
      end

      context 'exit of first gets is exit' do
        it do
          allow(subject).to receive(:card) { fake_cards }
          subject.instance_variable_set(:@current_account, subject)
          expect(subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          subject.destroy_card
        end
      end

      context 'incorrect input of card number' do
        before do
          allow(subject).to receive(:card) { fake_cards }
          subject.instance_variable_set(:@current_account, subject)
        end

        it do
          allow(subject).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { subject.destroy_card }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end

        it do
          allow(subject).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { subject.destroy_card }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end
      end

      context 'correct input of card number' do
        allow(subject).to receive(:card) { fake_cards }
        subject.instance_variable_set(:@current_account, subject)
      end
    end
  end
end
