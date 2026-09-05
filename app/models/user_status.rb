class UserStatus < ApplicationRecord
  belongs_to :user

  # ユーザーがガチャを回せる上限
  RANDOM_GACHA_LIMIT = 10

  def random_gacha_available?
    random_gacha_date != Date.current || random_gacha_count < RANDOM_GACHA_LIMIT
  end

  validates :level, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :experimence, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :login_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :login_streak, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :longest_login_streak, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :action_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :action_streak, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :longest_action_streak, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :last_login_date, presence: true, comparison: { less_than_or_equal_to: Date.current }
  validates :last_action_date, comparison: { less_than_or_equal_to: Date.current }, allow_nil: true
  validates :random_gacha_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :random_gacha_date, comparison: { less_than_or_equal_to: Date.current }, allow_nil: true
end
