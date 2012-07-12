# Make Rack::Cache not break on Latin-1 query params.
# https://github.com/rtomayko/rack-cache/issues/47
class Rack::Cache::Key
  def unescape(x)
    super(x).encode("UTF-8", "ISO8859-1")
  end

  def escape(x)
    super(x.encode("ISO8859-1", "UTF-8")).encode("UTF-8", "ISO8859-1")
  end
end
