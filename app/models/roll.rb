# == Schema Information
#
# Table name: rolls
#
#  id                :bigint           not null, primary key
#  pins_knocked_down :integer          default(0), not null
#  roll_number       :string           default("first"), not null
#  type              :string           default("normal"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  turn_id           :bigint           not null
#
# Indexes
#
#  index_rolls_on_turn_id  (turn_id)
#
class Roll < ApplicationRecord
end
