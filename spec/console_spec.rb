RSpec.describe Console do
  let(:current_subject) { described_class.new }

  before do
    stub_const('Account::FILE_PATH', FileHelper::OVERRIDABLE_FILENAME)
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
        expect(current_subject).to receive(:puts).with(I18n.t(:console))
        current_subject.console
      end
    end
  end

  describe '#create_card' do
    context 'with correct output' do
      it do
        current_subject.account.instance_variable_set(:@current_account, current_subject.account)
        expect(current_subject).to receive(:puts).with(I18n.t(:create_card))
        expect(current_subject).to receive_message_chain(:gets, :chomp) { 'usual' }

        current_subject.create_card
      end
    end

    context 'when incorrect card choose' do
      it do
        current_subject.account.instance_variable_set(:@current_account, current_subject.account)
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return('test', 'usual')

        expect { current_subject.create_card }.to raise_error(BankErrors::WrongCardType)
      end
    end
  end

  describe '#show_cards' do
    let(:cards) { [UsualCard.new, VirtualCard.new] }

    it 'display cards if there are any' do
      current_subject.instance_variable_set(:@current_account, instance_double('Account', card: cards))
      cards.each { |card| expect(current_subject).to receive(:puts).with("- #{card.number}, #{card.type}") }
      current_subject.show_cards
    end

    it 'outputs error if there are no active cards' do
      current_subject.instance_variable_set(:@current_account, instance_double('Account', card: []))
      expect { current_subject.show_cards }.to raise_error(BankErrors::NoActiveCard)
    end
  end

  describe '#destroy_card' do
    context 'without cards' do
      it 'shows message about not active cards' do
        current_subject.instance_variable_set(:@current_account, instance_double('Account', card: []))
        expect { current_subject.destroy_card }.to raise_error(BankErrors::NoActiveCard)
      end
    end

    context 'with cards' do
      let(:card_one) { VirtualCard.new }
      let(:card_two) { VirtualCard.new }
      let(:fake_cards) { [card_one, card_two] }
      let(:message) { [PhrasesHelper::COMMON_PHRASES[:if_you_want_to_delete]] }

      context 'with correct outout' do
        it do
          current_subject.instance_variable_set(:@current_account, current_subject.account)
          allow(current_subject.current_account).to receive(:card) { fake_cards }
          allow(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          fake_cards.each_with_index do |card, index|
            message << I18n.t(:show_card, num: card.number, type: card.type, index: index + 1)
          end
          message << I18n.t(:press_exit)
          expect { current_subject.destroy_card }.to output(/#{message.join("\n")}/).to_stdout
        end
      end

      context 'when exit if first gets is exit' do
        it do
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
          expect { current_subject.destroy_card }.to output(/#{PhrasesHelper::ERROR_PHRASES[:wrong_number]}/).to_stdout
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { current_subject.destroy_card }.to output(/#{PhrasesHelper::ERROR_PHRASES[:wrong_number]}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:accept_for_deleting) { 'y' }
        let(:reject_for_deleting) { 'asdf' }
        let(:deletable_card_number) { 1 }

        before do
          current_subject.instance_variable_set(:@current_account, current_subject.account)
          current_subject.current_account.instance_variable_set(:@card, fake_cards)
          allow(current_subject.account).to receive(:accounts) { [current_subject.account] }
        end

        it 'decline deleting' do
          commands = [deletable_card_number, reject_for_deleting]
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)

          expect { current_subject.destroy_card }.not_to change(current_subject.account.card, :size)
        end
      end
    end
  end

  describe '#destroy_account' do
    let(:cancel_input) { 'sdfsdfs' }
    let(:correct_login) { 'test' }
    let(:fake_login) { 'test1' }
    let(:fake_login2) { 'test2' }

    it 'with correct outout' do
      expect(current_subject).to receive_message_chain(:gets, :chomp) {}
      expect { current_subject.destroy_account }.to output(PhrasesHelper::COMMON_PHRASES[:destroy_account]).to_stdout
    end

    it 'doesnt delete account' do
      expect(current_subject).to receive_message_chain(:gets, :chomp) { cancel_input }

      current_subject.destroy_account

      expect(File.exist?(FileHelper::OVERRIDABLE_FILENAME)).to be false
    end
  end

  describe '#put_money' do
    context 'without cards' do
      it 'shows message about not active cards' do
        current_subject.instance_variable_set(:@current_account, instance_double('Account', card: []))
        expect { current_subject.put_money }.to raise_error(BankErrors::NoActiveCard)
      end
    end

    context 'with cards' do
      let(:card_one) { VirtualCard.new }
      let(:card_two) { VirtualCard.new }
      let(:fake_cards) { [card_one, card_two] }
      let(:message) { [PhrasesHelper::COMMON_PHRASES[:choose_card]] }

      before do
        allow(card_one).to receive(:number).and_return 1
        allow(card_two).to receive(:number).and_return 2
      end

      context 'with correct outout' do
        it do
          current_subject.instance_variable_set(:@current_account, current_subject.account)
          allow(current_subject.current_account).to receive(:card) { fake_cards }
          allow(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          fake_cards.each_with_index do |card, index|
            message << I18n.t(:show_card, num: card.number, type: card.type, index: index + 1)
          end
          message << I18n.t(:press_exit)
          expect { current_subject.put_money }.to output(/#{message.join("\n")}/).to_stdout
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
          expect { current_subject.put_money }.to raise_error(BankErrors::WrongNumberError)
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { current_subject.put_money }.to raise_error(BankErrors::WrongNumberError)
        end
      end

      context 'with correct input of card number' do
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
          let(:commands) { [chosen_card_number, correct_money_amount_greater_than_tax] }

          it do
            expect { current_subject.put_money }.to output(/#{PhrasesHelper::COMMON_PHRASES[:input_amount]}/).to_stdout
          end
        end

        context 'with amount lower then 0' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            expect { current_subject.put_money }.to raise_error(BankErrors::WrongAmountError)
          end
        end

        context 'with tax greater than amount' do
          let(:commands) { [chosen_card_number, correct_money_amount_lower_than_tax] }

          it do
            expect { current_subject.put_money }.to raise_error(BankErrors::TaxTooHigh)
          end
        end

        context 'with tax lower than amount' do
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
              custom_card.balance!(default_balance)
            end
          end

          it do
            expect { current_subject.put_money }
              .to output(/#{PhrasesHelper::COMMON_PHRASES[:input_amount]}/).to_stdout
          end
        end
      end
    end
  end

  describe '#withdraw_money' do
    context 'without cards' do
      it 'shows message about not active cards' do
        current_subject.instance_variable_set(:@current_account, instance_double('Account', card: []))
        expect { current_subject.withdraw_money }.to raise_error(BankErrors::NoActiveCard)
      end
    end

    context 'with cards' do
      let(:card_one) { CapitalistCard.new }
      let(:card_two) { CapitalistCard.new }
      let(:fake_cards) { [card_one, card_two] }
      let(:message) { [PhrasesHelper::COMMON_PHRASES[:choose_card_withdrawing]] }

      context 'with correct outout' do
        it do
          current_subject.instance_variable_set(:@current_account, current_subject.account)
          allow(current_subject.current_account).to receive(:card) { fake_cards }
          allow(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          fake_cards.each_with_index do |card, index|
            message << I18n.t(:show_card, num: card.number, type: card.type, index: index + 1)
          end
          message << I18n.t(:press_exit)
          expect { current_subject.withdraw_money }
            .to output(/#{message.join("\n")}/).to_stdout
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
          expect { current_subject.withdraw_money }.to raise_error(BankErrors::WrongNumberError)
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { current_subject.withdraw_money }.to raise_error(BankErrors::WrongNumberError)
        end
      end

      context 'with correct input of card number' do
        let(:chosen_card_number) { 1 }
        let(:correct_money_amount_lower_than_tax) { 5 }
        let(:correct_money_amount_greater_than_tax) { 100 }

        before do
          current_subject.instance_variable_set(:@current_account, current_subject.account)
          current_subject.current_account.instance_variable_set(:@card, fake_cards)

          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)
        end

        context 'with correct output' do
          let(:commands) { [chosen_card_number, correct_money_amount_lower_than_tax] }

          it do
            expect { current_subject.withdraw_money }
              .to output(/#{PhrasesHelper::COMMON_PHRASES[:withdraw_amount]}/).to_stdout
          end
        end

        context 'with correct output greater than tax' do
          let(:commands) { [chosen_card_number, correct_money_amount_greater_than_tax] }

          it do
            expect { current_subject.withdraw_money }.to raise_error(BankErrors::NoMoneyError)
          end
        end
      end
    end
  end

  describe '#send_money' do
    context 'without cards' do
      it 'shows message about not active cards' do
        current_subject.instance_variable_set(:@current_account, instance_double('Account', card: []))
        expect { current_subject.send_money }.to raise_error(BankErrors::NoActiveCard)
      end
    end

    context 'with cards' do
      let(:card_one) { CapitalistCard.new }
      let(:card_two) { CapitalistCard.new }
      let(:fake_cards) { [card_one, card_two] }
      let(:message) { [PhrasesHelper::COMMON_PHRASES[:choose_card]] }

      context 'with correct outout' do
        it do
          current_subject.instance_variable_set(:@current_account, current_subject.account)
          allow(current_subject.current_account).to receive(:card) { fake_cards }
          allow(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }

          fake_cards.each_with_index do |card, index|
            message << I18n.t(:show_card, num: card.number, type: card.type, index: index + 1)
          end
          message << I18n.t(:press_exit)
          expect { current_subject.send_money }
            .to output(/#{message.join("\n")}/).to_stdout
        end
      end

      context 'when exit if first gets is exit' do
        it do
          current_subject.instance_variable_set(:@current_account, current_subject.account)
          allow(current_subject.current_account).to receive(:card) { fake_cards }
          expect(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          current_subject.send_money
        end
      end

      context 'with incorrect input of card number' do
        before do
          current_subject.instance_variable_set(:@current_account, current_subject.account)
          allow(current_subject.current_account).to receive(:card) { fake_cards }
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { current_subject.send_money }.to raise_error(BankErrors::WrongNumberError)
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { current_subject.send_money }.to raise_error(BankErrors::WrongNumberError)
        end
      end

      context 'with correct input of card number' do
        let(:chosen_card_number) { 1 }
        let(:recipient_card) { card_two }
        let(:correct_money_amount_lower_than_tax) { 5 }
        let(:correct_money_amount) { 20 }
        let(:correct_money_amount_greater_than_tax) { 100 }

        before do
          current_subject.instance_variable_set(:@current_account, current_subject.account)
          current_subject.current_account.instance_variable_set(:@card, fake_cards)
          allow(current_subject.account).to receive(:accounts) { [current_subject.account] }

          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)
        end

        context 'with correct output' do
          let(:commands) { [chosen_card_number, recipient_card.number, correct_money_amount] }

          it do
            expect { current_subject.send_money }
              .to output(/#{PhrasesHelper::COMMON_PHRASES[:withdraw_amount]}/).to_stdout
          end
        end

        context 'with correct output lower than tax' do
          let(:commands) { [chosen_card_number, recipient_card.number, correct_money_amount_lower_than_tax] }

          it do
            expect { current_subject.send_money }.to raise_error(BankErrors::TaxTooHigh)
          end
        end

        context 'with correct output greater than tax' do
          let(:commands) { [chosen_card_number, recipient_card.number, correct_money_amount_greater_than_tax] }

          it do
            expect { current_subject.send_money }.to raise_error(BankErrors::NoMoneyError)
          end
        end
      end
    end
  end
end
