require 'spec_helper'

RSpec.describe ChoresKit::Chore do
  subject { ChoresKit::Chore.new(name) }

  let(:name) { :rspec }

  describe '.initialize' do
    it 'accepts a name parameter' do
      expect(subject).to be_truthy
    end

    it 'sets the name' do
      expect(subject.name).to eq(:rspec)
    end
  end

  describe '#description' do
  end

  describe '#schedule' do
  end

  describe '#retry_failed' do
  end

  describe '#task' do
  end

  describe '#run' do
  end

  describe '#notify' do
  end
end
