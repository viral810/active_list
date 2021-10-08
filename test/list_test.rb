# frozen_string_literal: true

require "test_helper"

class ListItem < ActiveRecord::Base
  active_list
end

module ActiveList
  class ListTest < Minitest::Test
    def setup
      setup_db
      4.times { ListItem.create }
    end

    def teardown
      teardown_db
    end

    def test_insert_at_first_position
      record = ListItem.create

      record.insert_at_position(1)
      record.reload

      # [[id, position]]
      assert_equal [[1, 2], [2, 3], [3, 4], [4, 5], [5, 1]], ListItem.all.pluck(:id, :position)
      assert_equal record.id, 5
      assert_equal record.position, 1
    end

    def test_insert_at_second_position
      record = ListItem.create

      record.insert_at_position(2)
      record.reload

      # [[id, position]]
      assert_equal [[1, 1], [2, 3], [3, 4], [4, 5], [5, 2]], ListItem.all.pluck(:id, :position)
      assert_equal record.id, 5
      assert_equal record.position, 2
    end

    def test_insert_at_third_position
      record = ListItem.create

      record.insert_at_position(3)
      record.reload

      # [[id, position]]
      assert_equal [[1, 1], [2, 2], [3, 4], [4, 5], [5, 3]], ListItem.all.pluck(:id, :position)
      assert_equal record.id, 5
      assert_equal record.position, 3
    end
  end
end
