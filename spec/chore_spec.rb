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
  end

  describe '#run' do
  end

  describe '#notify' do
  end
end
