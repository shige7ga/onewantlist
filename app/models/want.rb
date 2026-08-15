class Want < ApplicationRecord
  belongs_to :user

  validates :content, presence: true, length: { maximum: 400 }

  enum :status, {
    not_started: 0,
    in_progress: 1,
    completed: 2
  }
end
