require 'rails_helper'

RSpec.describe "Top", type: :system do
  it "トップページを表示できる" do
    visit root_path

    expect(page).to have_css("body")
  end
end
