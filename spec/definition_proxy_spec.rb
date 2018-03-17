require 'spec_helper'

RSpec.describe ChoresKit::DefinitionProxy do
  subject { ChoresKit::DefinitionProxy.new(name) }

  let(:name) { :rspec }

  describe '.initialize' do
    it 'accepts a name parameter' do
      expect(subject).to be
    end

    it 'sets the name' do
      expect(subject.name).to eq(:rspec)
    end
  end

  describe '.chore' do
    it 'returns a Chore object' do
      expect(subject.chore).to be_instance_of(ChoresKit::Chore)
    end
  end

  describe '#method_missing' do
    let(:metadata) { subject.chore.instance_variable_get(:@metadata) }
    let(:notifications) { subject.chore.instance_variable_get(:@notifications) }
    let(:tasks) { subject.chore.instance_variable_get(:@tasks) }
    let(:task) { tasks.first }

    context 'with options' do
      context 'with a block' do
        it 'sets Chore attributes' do
          subject.task(:rspec) { 'Swallow what happens inside this block' }

          expect(task[:task].name).to eq(:rspec)
          expect(task[:task]).to be_kind_of(ChoresKit::Task)
        end
      end

      context 'without a block' do
        it 'sets Chore attributes' do
          subject.description('A few words')

          expect(metadata[:description]).to eq('A few words')
        end
      end
    end

    context 'without options' do
      context 'with a block' do
        it 'sets Chore attributes' do
          subject.notify { 'Swallow what happens inside this block' }

          expect(notifications).to be
        end
      end
    end
  end
end
