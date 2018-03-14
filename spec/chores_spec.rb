require 'spec_helper'

RSpec.describe Chores do
  subject { Chores.define(name) }

  let(:name) { :rspec }

  describe '.define' do
    it 'accepts a name parameter' do
      expect(subject.name).to be
    end

    it 'accepts a block' do
      chore = Chores.define name { 'Swallow what happens inside this block' }

      expect(chore).to be
    end

    it 'sets the name' do
      expect(subject.name).to eq(:rspec)
    end

    it 'returns a Chore object' do
      expect(subject).to be_instance_of(ChoresKit::Chore)
    end
  end
end
