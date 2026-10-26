class Memo < ApplicationRecord
  belongs_to :user

  validates :content, length: { max: 2000 }
end
