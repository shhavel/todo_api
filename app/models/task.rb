class Task < ApplicationRecord
  validates_presence_of :name
  validates_presence_of :slug
  validates_uniqueness_of :slug
end
