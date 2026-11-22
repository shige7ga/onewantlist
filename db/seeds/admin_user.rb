admin_email = ENV["ADMIN_EMAIL"].presence
admin_password = ENV["ADMIN_PASSWORD"].presence

if admin_email.nil? && admin_password.nil?
  puts "初期管理者の設定がないためスキップします"
elsif admin_email.nil? || admin_password.nil?
  raise "初期管理者の環境変数が不足しています"
else
  Users::CreateInitialAdmin.new(
    email: admin_email,
    password: admin_password
  ).call

  puts "初期管理者の設定が完了しました"
end
