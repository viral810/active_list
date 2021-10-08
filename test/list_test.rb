# frozen_string_literal: true

require "test_helper"

class Mixin < ActiveRecord::Base
  self.table_name = "mixins"

  act_as_list
end

module ActiveList
  class ListTest < Minitest::Test
    def setup
      setup_db
      4.times { Mixin.create }
    end

    def teardown
      teardown_db
    end

    def test_insert_at_first_position
      record = Mixin.create

      record.insert_at_position(1)
    end
  end
end
