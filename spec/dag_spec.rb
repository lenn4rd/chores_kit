require 'spec_helper'

RSpec.describe ChoresKit::DAG do
  describe '.initialize' do
    it 'returns a ChoresKit::DAG instance' do
      expect(subject).to be_instance_of(ChoresKit::DAG)
    end
  end

  describe '#add_edge' do
    it 'adds an edge' do
      v1 = subject.add_vertex(:origin)
      v2 = subject.add_vertex(:destination)

      expect(subject.vertices.size).to eq(2)
      expect { subject.add_edge(from: v1, to: v2) }.to change { subject.edges.size }.by(1)
    end
  end

  describe '#add_vertex' do
    it 'adds a vertex' do
      expect { subject.add_vertex }.to change { subject.vertices.size }.by(1)
    end
  end
end
