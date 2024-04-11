# == Schema Information
#
# Table name: players
#
#  id   :bigint           not null, primary key
#  name :string           default("Default player"), not null
#
class Player < ApplicationRecord
end
