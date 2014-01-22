if Rails.env.test? || Rails.env.development?
  Teaspoon.setup do |config|

    config.suite do |suite|
      suite.matcher = "test/javascripts/**/*_test.{js,js.coffee,coffee}"
      suite.javascripts = ["teaspoon/qunit"]
      suite.helper = "test_helper"
    end

  end
end
