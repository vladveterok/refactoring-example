RSpec.describe Account do
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
    no_active_cards: "There is no active cards!\n",
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
    usual: UsualCard.new,
    capitalist: CapitalistCard.new,
    virtual: VirtualCard.new
  }.freeze

  let(:current_subject) { described_class.new }

  describe '#create' do
    let(:success_name_input) { 'Denis' }
    let(:success_age_input) { '72' }
    let(:success_login_input) { 'Denis' }
    let(:success_password_input) { 'Denis1993' }
    let(:success_inputs) { [success_name_input, success_age_input, success_login_input, success_password_input] }

    context 'with success result' do
      it 'write to file Account instance' do
        current_subject.instance_variable_set(:@file_path, OVERRIDABLE_FILENAME)
        current_subject.create
        expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
        accounts = YAML.load_file(OVERRIDABLE_FILENAME)
        expect(accounts).to be_a Array
        expect(accounts.size).to be 1
        accounts.map { |account| expect(account).to be_a described_class }
      end
    end
  end

  describe '#create_card' do
    context 'when correct card choose' do
      before do
        # allow(current_subject).to receive(:card) # .and_return([])
        allow(current_subject).to receive(:accounts) { [current_subject] }
        current_subject.instance_variable_set(:@file_path, OVERRIDABLE_FILENAME)
        current_subject.instance_variable_set(:@current_account, current_subject)
      end

      after do
        File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
      end

      CARDS.each do |card_type, card_instance|
        it "create card with #{card_type} type" do
          # expect(current_subject).to receive_message_chain(:gets, :chomp) { card_instance.type }
          expect(current_subject).to receive(:card) { card_instance }

          current_subject.create_card

          expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
          file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
          # binding.pry
          expect(file_accounts.first.card.type).to eq card_instance.type
          expect(file_accounts.first.card.balance).to eq card_instance.balance
          expect(file_accounts.first.card.number.length).to be 16
        end
      end
    end
  end

  describe '#put_money' do
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
          allow(current_subject).to receive(:card) { fake_cards }
          current_subject.instance_variable_set(:@current_account, current_subject)
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
          allow(current_subject).to receive(:card) { fake_cards }
          current_subject.instance_variable_set(:@current_account, current_subject)
          expect(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          current_subject.put_money
        end
      end

      context 'with incorrect input of card number' do
        before do
          allow(current_subject).to receive(:card) { fake_cards }
          current_subject.instance_variable_set(:@current_account, current_subject)
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
          current_subject.instance_variable_set(:@card, fake_cards)
          current_subject.instance_variable_set(:@current_account, current_subject)
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
              expect { current_subject.put_money }.to output(/#{ERROR_PHRASES[:tax_higher]}/).to_stdout
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
        expect { current_subject.withdraw_money }.to output(/#{ERROR_PHRASES[:no_active_cards]}/).to_stdout
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
          allow(current_subject).to receive(:card) { fake_cards }
          current_subject.instance_variable_set(:@current_account, current_subject)
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
          allow(current_subject).to receive(:card) { fake_cards }
          current_subject.instance_variable_set(:@current_account, current_subject)
          expect(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          current_subject.withdraw_money
        end
      end

      context 'with incorrect input of card number' do
        before do
          allow(current_subject).to receive(:card) { fake_cards }
          current_subject.instance_variable_set(:@current_account, current_subject)
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
        let(:card_one) { CapitalistCard.new }
        let(:card_two) { CapitalistCard.new }
        let(:fake_cards) { [card_one, card_two] }
        let(:chosen_card_number) { 1 }
        let(:incorrect_money_amount) { -2 }
        let(:default_balance) { 50.0 }
        let(:correct_money_amount_lower_than_tax) { 5 }
        let(:correct_money_amount_greater_than_tax) { 50 }

        before do
          current_subject.instance_variable_set(:@card, fake_cards)
          current_subject.instance_variable_set(:@current_account, current_subject)
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
