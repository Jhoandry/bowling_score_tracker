# == Schema Information
#
# Table name: games
#
#  id         :bigint           not null, primary key
#  location   :string           default("Freeletics"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Game < ApplicationRecord
end
