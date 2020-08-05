RSpec.describe Account do
  let(:current_subject) { described_class.new }

  before do
    current_subject.instance_variable_set(:@file_path, FileHelper::OVERRIDABLE_FILENAME)
  end

  describe '#create' do
    context 'with success result' do
      before do
        current_subject.credentials(name: 'Denis', age: 72, login: 'denis', password: 'Denis1993') # name('Denis')
        # current_subject.age!(72)
        # current_subject.login!('denis')
        # current_subject.password!('Denis1993')
        allow(current_subject).to receive(:accounts).and_return([])
      end

      it 'write to file Account instance' do
        current_subject.instance_variable_set(:@file_path, FileHelper::OVERRIDABLE_FILENAME)
        current_subject.create
        expect(File.exist?(FileHelper::OVERRIDABLE_FILENAME)).to be true
        accounts = YAML.load_file(FileHelper::OVERRIDABLE_FILENAME)
        expect(accounts).to be_a Array
        expect(accounts.size).to be 1
        accounts.map { |account| expect(account).to be_a described_class }
      end
    end
  end

  describe '#create_card' do
    context 'when correct card choose' do
      before do
        allow(current_subject).to receive(:accounts) { [current_subject] }
        current_subject.instance_variable_set(:@file_path, FileHelper::OVERRIDABLE_FILENAME)
        current_subject.instance_variable_set(:@current_account, current_subject)
      end

      CardsHelper::CARDS.each do |card_type, card_instance|
        it "create card with #{card_type} type" do
          current_subject.create_card(card_type)

          expect(File.exist?(FileHelper::OVERRIDABLE_FILENAME)).to be true
          file_accounts = YAML.load_file(FileHelper::OVERRIDABLE_FILENAME)
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
        let(:deletable_card_number) { 1 }

        before do
          current_subject.instance_variable_set(:@card, fake_cards)
          current_subject.instance_variable_set(:@current_account, current_subject)
          current_subject.instance_variable_set(:@file_path, FileHelper::OVERRIDABLE_FILENAME)
          allow(current_subject).to receive(:accounts) { [current_subject] }
        end

        it 'accept deleting' do
          expect { current_subject.destroy_card(deletable_card_number) }
            .to change { current_subject.current_account.card.size }.by(-1)

          expect(File.exist?(FileHelper::OVERRIDABLE_FILENAME)).to be true
          file_accounts = YAML.load_file(FileHelper::OVERRIDABLE_FILENAME)
          expect(file_accounts.first.card).not_to include(card_one)
        end
      end
    end
  end

  describe '#destroy_account' do
    let(:correct_login) { 'test' }
    let(:fake_login) { 'test1' }
    let(:fake_login2) { 'test2' }
    let(:correct_account) { instance_double('Account', login: correct_login) }
    let(:fake_account) { instance_double('Account', login: fake_login) }
    let(:fake_account2) { instance_double('Account', login: fake_login2) }
    let(:accounts) { [correct_account, fake_account, fake_account2] }

    context 'when deleting' do
      it 'deletes account if user inputs is y' do
        expect(current_subject).to receive(:accounts) { accounts }
        current_subject.instance_variable_set(:@file_path, FileHelper::OVERRIDABLE_FILENAME)
        current_subject.instance_variable_set(:@current_account, instance_double('Account', login: correct_login))
        current_subject.destroy_account

        expect(File.exist?(FileHelper::OVERRIDABLE_FILENAME)).to be true
        file_accounts = YAML.load_file(FileHelper::OVERRIDABLE_FILENAME)
        expect(file_accounts).to be_a Array
        expect(file_accounts.size).to be 2
      end
    end
  end
end
