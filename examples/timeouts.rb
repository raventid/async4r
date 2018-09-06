require_relative "../lib/async4r"

class Example
  include Async4r

  async def heavy_task(number)
    sleep(5)

    "Task #{number} completed after 5 seconds"
  end

  def run_many_tasks
    results = await [heavy_task(1), heavy_task(2), heavy_task(3), heavy_task(4)]
  end
end

Example.new.run_many_tasks.each { |string| puts string }
