RSpec.describe Account do
  OVERRIDABLE_FILENAME = 'spec/fixtures/account.yml'

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
      end
    end
  end
end
