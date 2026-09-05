class Want < ApplicationRecord
  belongs_to :user

  validates :content, presence: true, length: { maximum: 400 }
  validates :status, presence: true
  validates :due_date, comparison: { greater_than_or_equal_to: Time.current }, allow_nil: true

  normalizes :content, with: ->(value) { value.strip.presence }

  enum :status, {
    not_started: 0,
    in_progress: 1,
    completed: 2
  }, validate: true
end
