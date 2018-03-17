module ChoresKit
  class DAG
    class Vertex < ::DAG::Vertex
      def name
        task.name
      end

      private

      def task
        self[:task]
      end
    end
  end
end
