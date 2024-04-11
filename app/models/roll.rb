# == Schema Information
#
# Table name: rolls
#
#  id                :bigint           not null, primary key
#  chance            :integer          default(1), not null
#  pins_knocked_down :integer          default(0), not null
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
  belongs_to :turn
  enum type: { normal: 'normal', spare: 'spare', strike: 'strike' }
end
