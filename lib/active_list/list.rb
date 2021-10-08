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
      def insert_at_position(new_position)
        raise ArgumentError, "position can only be positive number." unless new_position.positive?

        transaction do
          cols = %i[id position]
          # FIXME: cannot be select all, need to scope down to a specific column, such as parent_id
          # or active: true or should be scoped to multiple columns ideally
          values_list = self.class.all.select(*cols).each_with_index.each_with_object([]) do |(record, index), acc|
            # if updating current record, update to new poisition
            # else just choose the current position
            pos = if record.id == id
                    new_position
                  else
                    index + 1
                  end

            acc << {
              id: record.id,
              position: pos
            }
          end

          # reshuffle
          values_list = values_list.each do |value|
            next if value[:id] == id
            next if value[:position] < new_position

            value[:position] = value[:position] + 1
          end

          self.class.upsert_all(values_list)
        end
      end
    end
  end
end
