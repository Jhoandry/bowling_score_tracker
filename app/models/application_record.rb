# Base class for all ActiveRecord models in our service
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
