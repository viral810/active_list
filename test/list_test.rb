# frozen_string_literal: true

require "test_helper"

class Mixin < ActiveRecord::Base
  self.table_name = "mixins"
end

module ActiveList
  class ListTest < Minitest::Test
    def setup
      setup_db
      4.times { Mixin.create }
    end

    def teardown
      byebug
      teardown_db
    end

    def test_insert_at_first_position
      record = Mixin.create

      record.move_to_top
    end
  end
end
