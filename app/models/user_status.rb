class UserStatus < ApplicationRecord
  belongs_to :user

  validates :level, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :experimence, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :login_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :login_streak, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :longest_login_streak, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :want_registration_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :want_registration_streak, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :longest_want_registration_streak, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :last_login_date, presence: true, comparison: { less_than_or_equal_to: Date.current }
  validates :last_registration_date, comparison: { less_than_or_equal_to: Date.current }, allow_nil: true
end
