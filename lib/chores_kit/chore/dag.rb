require 'dag'

module ChoresKit
  class DAG < ::DAG
    def root
      return @vertices.first if @root.nil? && @edges.empty?

      @root || @vertices.detect { |v| v.ancestors.empty? && v.successors.any? }
    end

    def root!(vertex)
      @root = vertex
    end

    def find_by(name:)
      @vertices.detect { |v| v.name == name }
    end
  end
end
