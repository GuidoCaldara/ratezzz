class GetRatesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts "test"
  end
end
