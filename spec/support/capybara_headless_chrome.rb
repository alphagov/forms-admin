require "selenium/webdriver"

options = Selenium::WebDriver::Chrome::Options.new
options.add_preference(:download, prompt_for_download: false,
                                  default_directory: "/tmp/downloads")

options.add_preference(:browser, set_download_behavior: { behavior: "allow" })

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end

Capybara.register_driver :headless_chrome do |app|
  options.add_argument("--headless")
  options.add_argument("--disable-gpu")
  options.add_argument("--window-size=1280,1024")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")

  driver = Capybara::Selenium::Driver.new(app, browser: :chrome, options:)

  ### Allow file downloads in Google Chrome when headless!!!
  ### https://bugs.chromium.org/p/chromium/issues/detail?id=696481#c89
  bridge = driver.browser.send(:bridge)

  path = "/session/:session_id/chromium/send_command"
  path[":session_id"] = bridge.session_id

  bridge.http.call(:post, path, cmd: "Page.setDownloadBehavior",
                                params: {
                                  behavior: "allow",
                                  downloadPath: "/tmp/downloads",
                                })
  ###

  driver
end

Capybara.default_driver = Settings.show_browser_during_tests ? :chrome : :headless_chrome

Capybara.configure do |config|
  config.automatic_label_click = true
end
