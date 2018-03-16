require 'spec_helper'

RSpec.describe ChoresKit::Chore do
  subject { ChoresKit::Chore.new(name) }

  let(:name) { :rspec }
  let(:metadata) { subject.instance_variable_get(:@metadata) }

  describe '.initialize' do
    it 'accepts a name parameter' do
      expect(subject).to be_truthy
    end

    it 'sets the name' do
      expect(subject.name).to eq(:rspec)
    end
  end

  describe '#description' do
    it 'sets the description' do
      subject.description 'A few words'

      expect(metadata[:description]).to eq('A few words')
    end
  end

  describe '#schedule' do
    let(:schedule) { metadata[:schedule] }

    it 'stores the start time' do
      subject.schedule at: '00:00'

      expect(schedule).to have_key(:at)
    end

    it 'converts to Time object' do
      subject.schedule at: '00:00'

      expect(schedule[:at]).to be_kind_of(Time)
    end

    it 'uses UTC timezone' do
      subject.schedule at: '00:00'

      expect(schedule[:at].zone).to eq('UTC')
    end

    context 'with :at' do
      context 'when time' do
        it 'sets the start time' do
          subject.schedule at: '04:44'

          expect(schedule[:at].hour).to eq(4)
          expect(schedule[:at].min).to eq(44)
          expect(schedule[:at].sec).to eq(0)
        end
      end

      context 'when date' do
        it 'sets the start time' do
          subject.schedule at: '2018-03-11'

          expect(schedule[:at].year).to eq(2018)
          expect(schedule[:at].month).to eq(3)
          expect(schedule[:at].day).to eq(11)
          expect(schedule[:at].hour).to eq(0)
          expect(schedule[:at].min).to eq(0)
          expect(schedule[:at].sec).to eq(0)
        end
      end

      context 'when date and time' do
        it 'sets the start time' do
          subject.schedule at: '2018-03-11 02:33:44'

          expect(schedule[:at].year).to eq(2018)
          expect(schedule[:at].month).to eq(3)
          expect(schedule[:at].day).to eq(11)
          expect(schedule[:at].hour).to eq(2)
          expect(schedule[:at].min).to eq(33)
          expect(schedule[:at].sec).to eq(44)
        end
      end
    end

    context 'with :every' do
      it 'sets the interval' do
        subject.schedule every: 1.day, at: '00:00'

        expect(schedule[:every]).to be_instance_of(AS::Duration)
        expect(schedule[:every].value).to eq(86_400)
      end

      it 'throws an error for wrong data type' do
        expect { subject.schedule every: '30min' }.to raise_error(RuntimeError)
      end

      context 'without :at' do
        it 'throws an error' do
          expect { subject.schedule every: 2.hours }.to raise_error(RuntimeError)
        end
      end
    end
  end

  describe '#retry_failed' do
    let(:retry_failed) { metadata[:retry_failed] }

    context 'with :retries' do
      it 'sets the number of retries' do
        subject.retry_failed retries: 3

        expect(retry_failed[:retries]).to eq(3)
      end

      context 'without :wait' do
        it 'falls back to default' do
          subject.retry_failed retries: 3

          expect(retry_failed[:wait]).to eq(1.second)
        end
      end
    end

    context 'with :wait' do
      it 'sets the pause before retries' do
        subject.retry_failed wait: 1.minute

        expect(retry_failed[:wait]).to eq(1.minute)
      end

      it 'throws an error for wrong data type' do
        expect { subject.retry_failed wait: 10 }.to raise_error(RuntimeError)
      end

      context 'without :retries' do
        it 'falls back to default' do
          subject.retry_failed wait: 2.minutes

          expect(retry_failed[:retries]).to eq(1)
        end
      end
    end
  end

  describe '#task' do
    let(:tasks) { subject.instance_variable_get(:@tasks) }

    it 'adds the task' do
      expect { subject.task(:rspec) { 'Swallow what happens inside this block' } }.to change { tasks.size }.by(1)
    end

    context 'without options' do
      it 'throws an error' do
        expect { subject.task { 'Swallow what happens inside this block' } }.to raise_error(ArgumentError)
      end
    end

    context 'without a block' do
      it 'throws an error' do
        expect { subject.task :invalid }.to raise_error(RuntimeError)
      end
    end
  end

  describe '#run' do
  end

  describe '#notify' do
    let(:notifications) { subject.instance_variable_get(:@notifications) }

    context 'with one condition' do
      it 'adds one notification' do
        subject.notify(:successful) { 'Swallow what happens inside this block' }

        expect(notifications.size).to eq(1)
      end

      context 'when :successful' do
        it 'sets the notification condition' do
          subject.notify(:successful) { 'Swallow what happens inside this block' }

          expect(notifications).to have_key(:successful)
          expect(notifications).to have_key(:successful)
        end
      end

      context 'when :failed' do
        it 'sets the notification condition' do
          subject.notify(:failed) { 'Swallow what happens inside this block' }

          expect(notifications).to have_key(:failed)
        end
      end
    end

    context 'with multiple conditions' do
      it 'sets all notification conditions' do
        subject.notify(:successful, :failed) { 'Swallow what happens inside this block' }

        expect(notifications).to have_key(:successful)
        expect(notifications).to have_key(:failed)
      end
    end

    context 'without options' do
      it 'falls back to default' do
        subject.notify { 'Swallow what happens inside this block' }

        expect(notifications).to have_key(:successful)
        expect(notifications).to have_key(:failed)
      end
    end

    context 'without a block' do
      it 'throws an error' do
        expect { subject.notify :rspec }.to raise_error(RuntimeError)
      end
    end
  end
end
