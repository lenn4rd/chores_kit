require 'dag'

module ChoresKit
  class DAG < ::DAG
    def root
      @root ||= @vertices.detect { |v| v.ancestors.empty? }
    end

    def find_by(name:)
      @vertices.detect { |v| v.name == name }
    end

    def root=(vertex)
      @root = vertex
    end
  end
end
