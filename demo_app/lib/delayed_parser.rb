class DelayedParser
  def perform()
    Parser.new.extract_posts
  end
end