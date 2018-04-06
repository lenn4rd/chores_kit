require 'spec_helper'

RSpec.describe ChoresKit::DAG do
  describe '.initialize' do
    it 'returns a ChoresKit::DAG instance' do
      expect(subject).to be_instance_of(ChoresKit::DAG)
    end
  end

  describe '#root' do
    context 'with one vertex' do
      it 'selects the first vertex' do
        vertex = subject.add_vertex(:origin)

        expect(subject.root).to eq(vertex)
      end
    end

    context 'with unconnected vertices' do
      it 'selects the first vertex' do
        v1 = subject.add_vertex(:origin)
        v2 = subject.add_vertex(:destination)

        expect(subject.root).to eq(v1)
      end
    end

    context 'with connected vertices' do
      it 'selects the first vertex with successors' do
        v1 = subject.add_vertex(:origin)
        v2 = subject.add_vertex(:destination)
        subject.add_edge(from: v1, to: v2)

        expect(subject.root).to eq(v1)
      end
    end

    context 'with many partly connected vertices' do
      it 'selects the first vertex with successors' do
        v1 = subject.add_vertex(:orphaned)
        v2 = subject.add_vertex(:origin)
        v3 = subject.add_vertex(:destination)

        subject.add_edge(from: v2, to: v3)

        expect(subject.root).to eq(v2)
      end
    end
  end

  describe 'root!=' do
    let(:root) { subject.instance_variable_get(:@root) }
    let(:vertex) { subject.add_vertex(:new_root) }

    it 'assigns the root vertex' do
      subject.root!(vertex)

      expect(root).to eq(vertex)
    end

    context 'with multiple vertices' do
      let(:v1) { subject.add_vertex(:first) }
      let(:v2) { subject.add_vertex(:second) }

      it 'assigns a new root' do
        subject.root!(v2)

        expect(root).to eq(v2)
      end
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
