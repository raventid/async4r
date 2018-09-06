require_relative "../lib/async4r"

class Example
  include Async4r

  async def heavy_task(message)
    sleep(5)

    "Task completed after 5 seconds, your message is '#{message}'"
  end

  def run
    await heavy_task("Hi, great to see you!")
  end
end

puts Example.new.run
