require 'dag'

module ChoresKit
  class DAG < ::DAG
    def root
      @vertices.detect { |v| v.ancestors.empty? }
    end

    def add_vertex(payload = {})
      @vertices << Vertex.new(self, payload)
    end
  end
end
