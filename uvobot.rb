require 'dotenv'
require 'date'
require_relative 'lib/uvobot'

Dotenv.load
discourse_client = Uvobot::DiscourseClient.new(
  host: ENV.fetch('DISCOURSE_URL'),
  api_key: ENV.fetch('DISCOURSE_API_KEY'),
  api_username: ENV.fetch('DISCOURSE_USER'),
  local_store: Uvobot::Store::Manager.new(ENV.fetch('DATABASE_URL'))
)

notifiers = [
  Uvobot::Notifications::SlackNotifier.new(ENV.fetch('UVOBOT_SLACK_WEBHOOK')),
  Uvobot::Notifications::DiscourseNotifier.new(
    discourse_client,
    ENV.fetch('DISCOURSE_TARGET_CATEGORY'),
    Uvobot::UvoScraper.new
  )
]

Uvobot::Worker.new(
  Uvobot::UvoScraper.new,
  notifiers
).run(Date.today)
