# frozen_string_literal: true

module ActiveList
  module List
    module ClassMethods
      def act_as_list
        include ActiveList::List::InstanceMethods
      end
    end

    # Instance Methods
    module InstanceMethods
      def insert_at_position(position)
        raise ArgumentError, "position cannot be lower than top" unless position.positive?

        with_lock do
          cols = %i[id position]
          # FIXME: cannot be select all, need to scope down to a specific column, such as parent_id
          # or active: true or should be scoped to multiple columns ideally
          values_list = self.class.all.select(*cols).pluck(*cols)

          values = self.class.connection.visitor.compile(Arel::Nodes::ValuesList.new(values_list))
          table_name = self.class.table_name

          query = <<~EOS
            UPDATE #{table_name}
            SET
              position = temp_#{table_name}.position::integer
            FROM (#{values}) AS temp_#{table_name} (id, position)
            WHERE
              temp_#{table_name}.id = #{table_name}.id;
          EOS

          self.class.connection.execute(self.class.sanitize_sql(query))
        end
      end
    end
  end
end
