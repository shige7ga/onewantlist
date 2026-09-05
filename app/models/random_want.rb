class RandomWant < ApplicationRecord
  validates :content, presence: true, length: { maximum: 400 }, uniqueness: true
  normalizes :content, with: ->(value) { value.strip.presence }
end
