# frozen_string_literal: true

module ActiveList
  module List
    module ClassMethods
    end

    # Instance Methods
    module InstanceMethods
      def insert_at_position(position)
        raise ArgumentError, "position cannot be lower than top" unless position.positive?

        with_lock do
          where(id: items.pluck(:id)).update_all(position: nil)

          cols = %i[id position]
          values_list = items.map { |item| item.values_at(*cols) }

          values = connection.visitor.compile(Arel::Nodes::ValuesList.new(values_list))

          query = <<~EOS
            UPDATE #{table_name}
            SET
              position = temp_#{table_name}.position::integer
            FROM (#{values}) AS temp_#{table_name} (id, position)
            WHERE
              temp_#{table_name}.id::uuid = #{table_name}.id;
          EOS

          connection.execute(sanitize(query))
        end
      end
    end
  end
end
