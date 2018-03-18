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
    let(:task) { tasks.first }
    let(:tasks) { subject.instance_variable_get(:@tasks) }

    it 'adds the task' do
      expect { subject.task(:rspec) { 'Swallow what happens inside this block' } }.to change { tasks.size }.by(1)
    end

    it 'assigns the name' do
      subject.task(:rspec) { 'Swallow what happens inside this block' }

      expect(task.name).to eq(:rspec)
    end

    it 'assigns the payload' do
      subject.task(:rspec) { 'Swallow what happens inside this block' }

      expect(task.send(:task)).to be_instance_of(ChoresKit::Task)
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
    let(:edges) { subject.instance_variable_get(:@dag).edges }
    let(:root) { subject.instance_variable_get(:@dag).root }

    before do
      subject.task(:first) { 'Swallow what happens inside this block' }
    end

    context 'with one task defined' do
      context 'without options' do
        it 'runs the task' do
          subject.run(:first)

          expect(edges).to be_empty
        end

        it 'assumes root task implicitly' do
          subject.run(:first)

          expect(root.name).to eq(:first)
        end

        context 'when task does not exist' do
          it 'throws an error' do
            expect { subject.run(:non_existing) }.to raise_error(RuntimeError)
          end
        end
      end

      context 'with upstream task defined' do
        it 'throws an error' do
          expect { subject.run(:first, upstream: :non_existing) }.to raise_error(RuntimeError)
        end
      end

      context 'with downstream task defined' do
        it 'throws an error' do
          expect { subject.run(:first, downstream: :non_existing) }.to raise_error(RuntimeError)
        end
      end
    end

    context 'with multiple tasks defined' do
      before do
        subject.task(:second) { 'Swallow what happens inside this block' }
      end

      context 'without options' do
        it 'runs the task' do
          subject.run(:first)

          expect(edges).to be_empty
        end

        context 'when tasks are defined but not run' do
          it 'assigns an explicit root task' do
            subject.run(:second)

            expect(root.name).to eq(:second)
          end
        end

        context 'when task does not exist' do
          it 'throws an error' do
            expect { subject.run(:non_existing) }.to raise_error(RuntimeError)
          end
        end
      end

      context 'with upstream task defined' do
        it 'sets the dependent task' do
          subject.run(:second, upstream: :first)

          expect(edges.size).to eq(1)
          expect(edges.first.origin[:name]).to eq(:first)
          expect(edges.first.destination[:name]).to eq(:second)
        end

        context 'when upstream task does not exist' do
          it 'throws an error' do
            expect { subject.run(:first, upstream: :non_existing) }.to raise_error(RuntimeError)
          end
        end

        context 'when multiple upstream tasks are set' do
          it 'throws an error' do
            expect { subject.run(:first, upstream: [:second]) }.to raise_error(RuntimeError)
          end
        end
      end

      context 'with downstream task defined' do
        it 'sets the dependent task' do
          subject.run(:first, downstream: :second)

          expect(edges.size).to eq(1)
          expect(edges.first.origin[:name]).to eq(:first)
          expect(edges.first.destination[:name]).to eq(:second)
        end

        context 'when downstream task does not exist' do
          it 'throws an error' do
            expect { subject.run(:first, downstream: :non_existing) }.to raise_error(RuntimeError)
          end
        end

        context 'when multiple downstream tasks are set' do
          it 'throws an error' do
            expect { subject.run(:first, downstream: [:second]) }.to raise_error(RuntimeError)
          end
        end
      end
    end
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
