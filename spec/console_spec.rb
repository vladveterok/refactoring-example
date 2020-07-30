RSpec.describe Console do
  OVERRIDABLE_FILENAME = 'spec/fixtures/account.yml'.freeze

  COMMON_PHRASES = {
    create_first_account: "There is no active accounts, do you want to be the first?[y/n]\n",
    destroy_account: "Are you sure you want to destroy account?[y/n]\n",
    if_you_want_to_delete: 'If you want to delete:',
    choose_card: 'Choose the card for putting:',
    choose_card_withdrawing: 'Choose the card for withdrawing:',
    input_amount: 'Input the amount of money you want to put on your card',
    withdraw_amount: 'Input the amount of money you want to withdraw'
  }.freeze

  HELLO_PHRASES = [
    'Hello, we are RubyG bank!',
    '- If you want to create account - press `create`',
    '- If you want to load account - press `load`',
    '- If you want to exit - press `exit`'
  ].freeze

  ASK_PHRASES = {
    name: 'Enter your name',
    login: 'Enter your login',
    password: 'Enter your password',
    age: 'Enter your age'
  }.freeze

  # rubocop:disable Metrics/LineLength

  CREATE_CARD_PHRASES = [
    'You could create one of 3 card types',
    '- Usual card. 2% tax on card INCOME. 20$ tax on SENDING money from this card. 5% tax on WITHDRAWING money. For creation this card - press `usual`',
    '- Capitalist card. 10$ tax on card INCOME. 10% tax on SENDING money from this card. 4$ tax on WITHDRAWING money. For creation this card - press `capitalist`',
    '- Virtual card. 1$ tax on card INCOME. 1$ tax on SENDING money from this card. 12% tax on WITHDRAWING money. For creation this card - press `virtual`',
    '- For exit - press `exit`'
  ].freeze

  # rubocop:enable Metrics/LineLength

  ACCOUNT_VALIDATION_PHRASES = {
    name: {
      first_letter: 'Your name must not be empty and starts with first upcase letter'
    },
    login: {
      present: 'Login must present',
      longer: 'Login must be longer then 4 symbols',
      shorter: 'Login must be shorter then 20 symbols',
      exists: 'Such account is already exists'
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
    no_active_cards: "There is no active cards!",
    wrong_card_type: "Wrong card type. Try again!\n",
    wrong_number: "You entered wrong number!\n",
    correct_amount: 'You must input correct amount of money',
    tax_higher: 'Your tax is higher than input amount'
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

  let(:current_subject) { described_class.new }

  before do
    current_subject.account.instance_variable_set(:@file_path, OVERRIDABLE_FILENAME)
  end

  describe '#console' do
    context 'when correct method calling' do
      after do
        current_subject.console
      end

      it 'create account if input is create' do
        allow(current_subject).to receive_message_chain(:gets, :chomp) { 'create' }
        expect(current_subject).to receive(:create)
      end

      it 'load account if input is load' do
        allow(current_subject).to receive_message_chain(:gets, :chomp) { 'load' }
        expect(current_subject).to receive(:load)
      end

      it 'leave app if input is exit or some another word' do
        allow(current_subject).to receive_message_chain(:gets, :chomp) { 'another' }
        expect(current_subject).to receive(:exit)
      end
    end

    context 'with correct outout' do
      it do
        allow(current_subject).to receive_message_chain(:gets, :chomp) { 'test' }
        allow(current_subject).to receive(:exit)
        # HELLO_PHRASES.each { |phrase| expect(current_subject).to receive(:puts).with(phrase) }
        expect(current_subject).to receive(:puts).with(I18n.t(:console))
        current_subject.console
      end
    end
  end

  describe '#create' do
    let(:success_name_input) { 'Denis' }
    let(:success_age_input) { '72' }
    let(:success_login_input) { 'Denis' }
    let(:success_password_input) { 'Denis1993' }
    let(:success_inputs) { [success_name_input, success_age_input, success_login_input, success_password_input] }

    before { current_subject.account }

    context 'with success result' do
      before do
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*success_inputs)
        allow(current_subject).to receive(:main_menu)
        allow(current_subject).to receive(:accounts).and_return([]) # FOR ACCOUNT???????
      end

      after do
        File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
      end

      it 'with correct outout' do
        allow(File).to receive(:open)
        ASK_PHRASES.values.each { |phrase| expect(current_subject).to receive(:puts).with(phrase) }
        ACCOUNT_VALIDATION_PHRASES.values.map(&:values).each do |phrase|
          expect(current_subject).not_to receive(:puts).with(phrase)
        end
        current_subject.create
      end
    end

    context 'with errors' do
      before do
        all_inputs = current_inputs + success_inputs
        allow(File).to receive(:open)
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*all_inputs)
        allow(current_subject).to receive(:main_menu)
        allow(current_subject).to receive(:accounts).and_return([])
      end

      context 'with name errors' do
        context 'without small letter' do
          let(:error_input) { 'some_test_name' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:name][:first_letter] }
          let(:current_inputs) { [error_input, success_age_input, success_login_input, success_password_input] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end
      end

      context 'with login errors' do
        let(:current_inputs) { [success_name_input, success_age_input, error_input, success_password_input] }

        context 'when present' do
          let(:error_input) { '' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:present] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when longer' do
          let(:error_input) { 'E' * 3 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:longer] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when shorter' do
          let(:error_input) { 'E' * 21 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:shorter] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when exists' do
          let(:error_input) { 'Denis1345' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:exists] }

          before do
            allow(current_subject.account).to receive(:accounts) { [instance_double('Account', login: error_input)] }
          end

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end
      end

      context 'with age errors' do
        let(:current_inputs) { [success_name_input, error_input, success_login_input, success_password_input] }
        let(:error) { ACCOUNT_VALIDATION_PHRASES[:age][:length] }

        context 'with length minimum' do
          let(:error_input) { '22' }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'with length maximum' do
          let(:error_input) { '91' }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end
      end

      context 'with password errors' do
        let(:current_inputs) { [success_name_input, success_age_input, success_login_input, error_input] }

        context 'when absent' do
          let(:error_input) { '' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:password][:present] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when longer' do
          let(:error_input) { 'E' * 5 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:password][:longer] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when shorter' do
          let(:error_input) { 'E' * 31 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:password][:shorter] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end
      end
    end
  end

  describe '#load' do
    context 'without active accounts' do
      it do
        expect(current_subject).to receive(:accounts).and_return([])
        expect(current_subject).to receive(:create_the_first_account).and_return([])
        current_subject.load
      end
    end

    context 'with active accounts' do
      let(:login) { 'Johnny' }
      let(:password) { 'johnny1' }

      before do
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*all_inputs)
        # allow(current_subject).to receive(:accounts) { [instance_double('Account', login: login, password: password)] }
        allow_any_instance_of(Account).to receive(:accounts) { [instance_double('Account', login: login, password: password)] }
      end

      context 'with correct outout' do
        let(:all_inputs) { [login, password] }

        it do
          expect(current_subject).to receive(:main_menu)
          [ASK_PHRASES[:login], ASK_PHRASES[:password]].each do |phrase|
            expect(current_subject).to receive(:puts).with(phrase)
          end
          current_subject.load
        end
      end

      context 'when account exists' do
        let(:all_inputs) { [login, password] }

        it do
          expect(current_subject).to receive(:main_menu)
          expect { current_subject.load }.not_to output(/#{ERROR_PHRASES[:user_not_exists]}/).to_stdout
        end
      end

      context 'when account doesn\t exists' do
        let(:all_inputs) { ['test', 'test', login, password] }

        it do
          # expect(current_subject).to receive(:main_menu)
          expect(current_subject).to receive(:console)
          # expect { current_subject.load }.to output(/#{ERROR_PHRASES[:user_not_exists]}/).to_stdout
          expect { current_subject.load }.to raise_error(BankErrors::NoAccountError)
        end
      end
    end
  end

  describe '#create_the_first_account' do
    let(:cancel_input) { 'sdfsdfs' }
    let(:success_input) { 'y' }

    it 'with correct outout' do
      expect(current_subject).to receive_message_chain(:gets, :chomp) {}
      expect(current_subject).to receive(:console)
      expect { current_subject.create_the_first_account }.to output(COMMON_PHRASES[:create_first_account]).to_stdout
    end

    it 'calls create if user inputs is y' do
      expect(current_subject).to receive_message_chain(:gets, :chomp) { success_input }
      expect(current_subject).to receive(:create)
      current_subject.create_the_first_account
    end

    it 'calls console if user inputs is not y' do
      expect(current_subject).to receive_message_chain(:gets, :chomp) { cancel_input }
      expect(current_subject).to receive(:console)
      current_subject.create_the_first_account
    end
  end

  describe '#main_menu' do
    let(:name) { 'John' }
    let(:commands) do
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
    end

    context 'with correct outout' do
      it do
        allow(current_subject).to receive(:show_cards)
        allow(current_subject).to receive(:exit)
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return('exit')
        current_subject.instance_variable_set(:@current_account, instance_double('Account', name: name))
        # binding.pry
        expect { current_subject.main_menu }.to output(/Welcome, #{name}/).to_stdout
        MAIN_OPERATIONS_TEXTS.each do |text|
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return('exit')
          expect { current_subject.main_menu }.to output(/#{text}/).to_stdout
        end
      end
    end
  end

  describe '#create_card' do
    context 'with correct output' do
      it do
        # CREATE_CARD_PHRASES.each { |phrase| expect(current_subject).to receive(:puts).with(phrase) }
        # current_subject.instance_variable_set(:@card, [])
        expect(current_subject).to receive(:puts).with(I18n.t(:create_card))
        current_subject.account.instance_variable_set(:@current_account, current_subject.account)
        # allow(current_subject).to receive(:accounts).and_return([])
        # allow(File).to receive(:open)
        expect(current_subject).to receive_message_chain(:gets, :chomp) { 'usual' }

        current_subject.create_card
      end
    end

    context 'when incorrect card choose' do
      it do
        # current_subject.instance_variable_set(:@card, [])
        current_subject.account.instance_variable_set(:@current_account, current_subject.account)
        # allow(File).to receive(:open)
        # allow(current_subject).to receive(:accounts).and_return([])
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return('test', 'usual')

        expect { current_subject.create_card }.to raise_error(BankErrors::WrongCardType)
      end
    end
  end

  describe '#show_cards' do
    # let(:cards) { [{ number: 1234, type: 'a' }, { number: 5678, type: 'b' }] }
    let(:cards) { [UsualCard.new, VirtualCard.new] }

    it 'display cards if there are any' do
      current_subject.instance_variable_set(:@current_account, instance_double('Account', card: cards))
      cards.each { |card| expect(current_subject).to receive(:puts).with("- #{card.number}, #{card.type}") }
      current_subject.show_cards
    end

    it 'outputs error if there are no active cards' do
      current_subject.instance_variable_set(:@current_account, instance_double('Account', card: []))
      # expect(current_subject).to receive(:puts).with(ERROR_PHRASES[:no_active_cards])
      expect { current_subject.show_cards }.to raise_error(BankErrors::NoActiveCard)
      # current_subject.show_cards
    end
  end

  describe '#destroy_card', focus: true do
    context 'without cards' do
      it 'shows message about not active cards' do
        current_subject.instance_variable_set(:@current_account, instance_double('Account', card: []))
        expect { current_subject.destroy_card }.to output(/#{ERROR_PHRASES[:no_active_cards]}/).to_stdout
      end
    end

    context 'with cards' do
      let(:card_one) { VirtualCard.new }
      let(:card_two) { VirtualCard.new }
      let(:fake_cards) { [card_one, card_two] }

      context 'with correct outout' do
        it do
          # allow_any_instance_of(Account).to receive(:card) { fake_cards }
          current_subject.instance_variable_set(:@current_account, current_subject.account)
          allow(current_subject.current_account).to receive(:card) { fake_cards }
          allow(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect { current_subject.destroy_card }.to output(/#{COMMON_PHRASES[:if_you_want_to_delete]}/).to_stdout
          # expect(current_subject).to receive(:puts).with(I18n.t(:if_want_delete))
          fake_cards.each_with_index do |card, i|
            message = I18n.t(:show_card, num: card.number, type: card.type, index: i + 1)
            # message = /- #{card.number}, #{card.type}, press #{i + 1}/
            expect { current_subject.destroy_card }.to output(message).to_stdout
          end
          current_subject.destroy_card
        end
      end

      context 'when exit if first gets is exit' do
        it do
          # allow_any_instance_of(Account).to receive(:card) { fake_cards }
          allow(current_subject.current_account).to receive(:card) { fake_cards }
          current_subject.account.instance_variable_set(:@current_account, current_subject.account)
          expect(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          current_subject.destroy_card
        end
      end

      context 'with incorrect input of card number' do
        before do
          allow(current_subject.current_account).to receive(:card) { fake_cards }
          current_subject.account.instance_variable_set(:@current_account, current_subject.account)
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { current_subject.destroy_card }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { current_subject.destroy_card }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:accept_for_deleting) { 'y' }
        let(:reject_for_deleting) { 'asdf' }
        let(:deletable_card_number) { 1 }

        before do
          # current_subject.account.instance_variable_set(:@file_path, OVERRIDABLE_FILENAME)
          current_subject.instance_variable_set(:@current_account, current_subject.account)
          current_subject.current_account.instance_variable_set(:@card, fake_cards)
          allow(current_subject.account).to receive(:accounts) { [current_subject.account] }
        end

        after do
          File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
        end
=begin
        it 'accept deleting' do
          commands = [deletable_card_number, accept_for_deleting]
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)

          expect { current_subject.destroy_card }.to change { current_subject.current_account.card.size }.by(-1)

          expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
          file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
          expect(file_accounts.first.card).not_to include(card_one)
        end
=end
        it 'decline deleting' do
          commands = [deletable_card_number, reject_for_deleting]
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)

          expect { current_subject.destroy_card }.not_to change(current_subject.account.card, :size)
        end
      end

    end
  end

  describe '#destroy_account', focus: true do
    let(:cancel_input) { 'sdfsdfs' }
    let(:success_input) { 'y' }
    let(:correct_login) { 'test' }
    let(:fake_login) { 'test1' }
    let(:fake_login2) { 'test2' }
    let(:correct_account) { instance_double('Account', login: correct_login) }
    let(:fake_account) { instance_double('Account', login: fake_login) }
    let(:fake_account2) { instance_double('Account', login: fake_login2) }
    let(:accounts) { [correct_account, fake_account, fake_account2] }

    after do
      File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
    end

    it 'with correct outout' do
      expect(current_subject).to receive_message_chain(:gets, :chomp) {}
      expect { current_subject.destroy_account }.to output(COMMON_PHRASES[:destroy_account]).to_stdout
    end

    context 'when deleting' do
      it 'deletes account if user inputs is y' do
        expect(current_subject).to receive_message_chain(:gets, :chomp) { success_input }
        expect(current_subject.account).to receive(:accounts) { accounts }
        # current_subject.account.instance_variable_set(:@file_path, OVERRIDABLE_FILENAME)
        current_subject.account.instance_variable_set(:@current_account, instance_double('Account', login: correct_login))

        current_subject.destroy_account

        expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
        file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
        expect(file_accounts).to be_a Array
        expect(file_accounts.size).to be 2
      end

      it 'doesnt delete account' do
        expect(current_subject).to receive_message_chain(:gets, :chomp) { cancel_input }

        current_subject.destroy_account

        expect(File.exist?(OVERRIDABLE_FILENAME)).to be false
      end
    end
  end

  describe '#put_money' do
    context 'without cards' do
      it 'shows message about not active cards' do
        current_subject.instance_variable_set(:@current_account, instance_double('Account', card: []))
        # expect { current_subject.put_money }.to output(/#{ERROR_PHRASES[:no_active_cards]}/).to_stdout
        expect { current_subject.put_money }.to raise_error(BankErrors::NoActiveCard)
      end
    end

    context 'with cards' do
      #let(:card_one) { { number: 1, type: 'test' } }
      #let(:card_two) { { number: 2, type: 'test2' } }
      let(:card_one) { VirtualCard.new }
      let(:card_two) { VirtualCard.new }
      let(:fake_cards) { [card_one, card_two] }

      before do
        allow(card_one).to receive(:number).and_return 1
        allow(card_two).to receive(:number).and_return 2
      end

      context 'with correct outout' do
        it do
          current_subject.instance_variable_set(:@current_account, current_subject.account)
          allow(current_subject.current_account).to receive(:card) { fake_cards }
          allow(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect { current_subject.put_money }.to output(/#{COMMON_PHRASES[:choose_card]}/).to_stdout
          fake_cards.each_with_index do |card, i|
            message = /- #{card.number}, #{card.type}, press #{i + 1}/
            expect { current_subject.put_money }.to output(message).to_stdout
          end
          current_subject.put_money
        end
      end

      context 'when exit if first gets is exit' do
        it do
          current_subject.instance_variable_set(:@current_account, current_subject.account)
          allow(current_subject.current_account).to receive(:card) { fake_cards }
          expect(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          current_subject.put_money
        end
      end

      context 'with incorrect input of card number' do
        before do
          current_subject.instance_variable_set(:@current_account, current_subject.account)
          allow(current_subject.current_account).to receive(:card) { fake_cards }
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { current_subject.put_money }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { current_subject.put_money }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        # let(:card_one) { { number: 1, type: 'capitalist', balance: 50.0 } }
        # let(:card_two) { { number: 2, type: 'capitalist', balance: 100.0 } }
        let(:card_one) { CapitalistCard.new }
        let(:card_two) { CapitalistCard.new }
        let(:fake_cards) { [card_one, card_two] }
        let(:chosen_card_number) { 1 }
        let(:incorrect_money_amount) { -2 }
        let(:default_balance) { 50.0 }
        let(:correct_money_amount_lower_than_tax) { 5 }
        let(:correct_money_amount_greater_than_tax) { 50 }

        before do
          current_subject.instance_variable_set(:@current_account, current_subject.account)
          current_subject.current_account.instance_variable_set(:@card, fake_cards)
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)
        end

        context 'with correct output' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            expect { current_subject.put_money }.to output(/#{COMMON_PHRASES[:input_amount]}/).to_stdout
          end
        end

        context 'with amount lower then 0' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            expect { current_subject.put_money }.to output(/#{ERROR_PHRASES[:correct_amount]}/).to_stdout
          end
        end

        context 'with amount greater then 0' do
          context 'with tax greater than amount' do
            let(:commands) { [chosen_card_number, correct_money_amount_lower_than_tax] }

            it do
              # expect { current_subject.put_money }.to output(/#{ERROR_PHRASES[:tax_higher]}/).to_stdout
              expect { current_subject.put_money }.to raise_error(BankErrors::TaxTooHigh)
            end
          end

          context 'with tax lower than amount' do
            #let(:custom_cards) do
            #  [
            #    { type: 'usual', balance: default_balance, tax: correct_money_amount_greater_than_tax * 0.02, number: 1 },
            #    { type: 'capitalist', balance: default_balance, tax: 10, number: 1 },
            #    { type: 'virtual', balance: default_balance, tax: 1, number: 1 }
            #  ]
            #end

            let(:custom_cards) do
              [
                UsualCard.new,
                CapitalistCard.new,
                VirtualCard.new
              ]
            end

            let(:commands) { [chosen_card_number, correct_money_amount_greater_than_tax] }

            before do
              custom_cards.each do |custom_card|
                custom_card.balance = default_balance
              end
            end

            after do
              File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
            end
          end
        end
      end
    end
  end

  describe '#withdraw_money' do
    context 'without cards' do
      it 'shows message about not active cards' do
        current_subject.instance_variable_set(:@current_account, instance_double('Account', card: []))
        # expect { current_subject.withdraw_money }.to output(/#{ERROR_PHRASES[:no_active_cards]}/).to_stdout
        expect { current_subject.withdraw_money }.to raise_error(BankErrors::NoActiveCard)
      end
    end

    context 'with cards' do
      # let(:card_one) { { number: 1, type: 'test' } }
      # let(:card_two) { { number: 2, type: 'test2' } }
      let(:card_one) { CapitalistCard.new }
      let(:card_two) { CapitalistCard.new }
      let(:fake_cards) { [card_one, card_two] }

      context 'with correct outout' do
        it do
          allow(current_subject.current_account).to receive(:card) { fake_cards }
          current_subject.instance_variable_set(:@current_account, current_subject.current_account)
          allow(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect { current_subject.withdraw_money }.to output(/#{COMMON_PHRASES[:choose_card_withdrawing]}/).to_stdout
          fake_cards.each_with_index do |card, i|
            message = /- #{card.number}, #{card.type}, press #{i + 1}/
            expect { current_subject.withdraw_money }.to output(message).to_stdout
          end
          current_subject.withdraw_money
        end
      end

      context 'when exit if first gets is exit' do
        it do
          allow(current_subject.current_account).to receive(:card) { fake_cards }
          current_subject.account.instance_variable_set(:@current_account, current_subject.account)
          expect(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          current_subject.withdraw_money
        end
      end

      context 'with incorrect input of card number' do
        before do
          allow(current_subject.current_account).to receive(:card) { fake_cards }
          current_subject.account.instance_variable_set(:@current_account, current_subject.account)
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { current_subject.withdraw_money }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { current_subject.withdraw_money }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        # let(:card_one) { { number: 1, type: 'capitalist', balance: 50.0 } }
        # let(:card_two) { { number: 2, type: 'capitalist', balance: 100.0 } }
        # let(:card_one) { CapitalistCard.new }
        # let(:card_two) { CapitalistCard.new }
        # let(:fake_cards) { [card_one, card_two] }
        let(:chosen_card_number) { 1 }
        let(:incorrect_money_amount) { -2 }
        let(:default_balance) { 50.0 }
        let(:correct_money_amount_lower_than_tax) { 5 }
        let(:correct_money_amount_greater_than_tax) { 50 }

        before do
          current_subject.instance_variable_set(:@current_account, current_subject.account)
          current_subject.current_account.instance_variable_set(:@card, fake_cards)

          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)
        end

        context 'with correct output' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            expect { current_subject.withdraw_money }.to output(/#{COMMON_PHRASES[:withdraw_amount]}/).to_stdout
          end
        end
      end
    end
  end
end
