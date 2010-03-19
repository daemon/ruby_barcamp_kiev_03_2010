class PostFinderLoop < Loops::AMQP::Bunny
  def process_message(page_url)
    info "Received page url: #{page_url}"
    @parser ||= LoopsParser.new
    
    @parser.find_posts(page_url) do |post_url|
      @exchange.publish(post_url, :key => 'genn.posts', :persistent => true)
    end
  end
end
