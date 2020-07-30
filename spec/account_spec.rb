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
          # expect(current_subject).to receive(:card) { card_instance }

          current_subject.create_card(card_type)

          expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
          file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
          expect(file_accounts.first.card.first.type).to eq card_instance.type
          expect(file_accounts.first.card.first.balance).to eq card_instance.balance
          expect(file_accounts.first.card.first.number.length).to be 16
        end
      end
    end
  end

  describe '#destroy_card' do
    context 'with cards' do
      let(:card_one) { VirtualCard.new }
      let(:card_two) { VirtualCard.new }
      let(:fake_cards) { [card_one, card_two] }

      context 'with correct input of card number' do
        let(:accept_for_deleting) { 'y' }
        let(:reject_for_deleting) { 'asdf' }
        let(:deletable_card_number) { 1 }

        before do
          # current_subject.account.instance_variable_set(:@file_path, OVERRIDABLE_FILENAME)
          current_subject.instance_variable_set(:@card, fake_cards)
          current_subject.instance_variable_set(:@current_account, current_subject)
          current_subject.instance_variable_set(:@file_path, OVERRIDABLE_FILENAME)
          allow(current_subject).to receive(:accounts) { [current_subject] }
        end

        after do
          File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
        end

        it 'accept deleting' do
          # commands = [deletable_card_number, accept_for_deleting]
          # allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)

          expect { current_subject.destroy_card(deletable_card_number) }.to change { current_subject.current_account.card.size }.by(-1)

          expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
          file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
          expect(file_accounts.first.card).not_to include(card_one)
        end
=begin
        it 'decline deleting' do
          commands = [deletable_card_number, reject_for_deleting]
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)

          expect { current_subject.destroy_card }.not_to change(current_subject.account.card, :size)
        end
=end
      end
    end
  end
end
