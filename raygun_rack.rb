# Because the built-in one has issues:
# https://github.com/MindscapeHQ/raygun4ruby/issues/6
# Inspired by https://github.com/honeybadger-io/honeybadger-ruby/blob/master/lib/honeybadger/rack.rb

class RaygunRack
  def initialize(app)
    @app = app
  end

  def call(env)
    response = @app.call(env)
  rescue Exception => exception
    track_exception(exception, env)
    raise
  else
    if framework_exception = env["rack.exception"] || env["sinatra.error"]
      track_exception(framework_exception, env)
    end
    response
  end

  private

  def track_exception(exception, env)
    env["raygun.error_id"] = Raygun.track_exception(exception, env)
  end
end
