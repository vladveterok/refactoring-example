RSpec.describe ConsoleMenu do
  let(:console) { Console.new }
  let(:current_account) { console.account }
  let(:current_subject) { described_class.new(current_account) }

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
        'DA' => :destroy_account
      }
    end

    context 'with correct outout' do
      it do
        allow(current_subject).to receive(:exit)
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return('exit')
        current_subject.instance_variable_set(:@current_account, instance_double('Account', name: name))

        expect { current_subject.main_menu }.to output(/Welcome, #{name}/).to_stdout
      end
    end

    context 'when commands used' do
      let(:undefined_command) { 'undefined' }

      it 'calls specific methods on predefined commands' do
        allow(current_subject).to receive(:exit)
        current_subject.instance_variable_set(:@current_account, instance_double('Account', name: name))

        commands.each do |command, method_name|
          expect(current_subject).to receive(method_name)
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(command, 'exit')
          current_subject.main_menu
        end
      end

      it 'outputs incorrect message on undefined command' do
        current_subject.instance_variable_set(:@current_account, instance_double('Account', name: name))
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(undefined_command, 'exit')
        expect { current_subject.main_menu }.to output(/#{PhrasesHelper::ERROR_PHRASES[:wrong_command]}/).to_stdout
      end
    end
  end
end
