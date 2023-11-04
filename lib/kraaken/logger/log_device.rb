# frozen_string_literal: true

class Kraaken::Logger::LogDevice
  def initialize(progress_proc)
    @progress_proc = progress_proc
  end

  def write(data)
    if (bar = progress_bar)
      bar.log(data)
    else
      $stdout.write(data)
    end
  end

  def close
  end

  private

  def progress_bar
    @progress_proc.call
  end
end
