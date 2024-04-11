# == Schema Information
#
# Table name: players
#
#  id   :bigint           not null, primary key
#  name :string           default("Default player"), not null
#
class Player < ApplicationRecord
  has_many :turns, dependent: :destroy
end
