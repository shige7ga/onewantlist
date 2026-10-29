class Memo < ApplicationRecord
  belongs_to :user

  validates :content, length: { maximum: 2000 }, allow_nil: true
end
