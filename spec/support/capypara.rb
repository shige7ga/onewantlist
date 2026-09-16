require "socket"

Capybara.register_driver :remote_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  options.add_argument("--headless=new")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--window-size=1680,1050")

  Capybara::Selenium::Driver.new(
    app,
    browser: :remote,
    url: ENV.fetch("SELENIUM_DRIVER_URL"),
    options: options
  )
end

unless ENV["CI"]
  Capybara.server_host = IPSocket.getaddress(Socket.gethostname)
  Capybara.server_port = 4444
  Capybara.app_host = "http://#{Capybara.server_host}:#{Capybara.server_port}"
end
