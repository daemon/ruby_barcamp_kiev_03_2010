class PostExtractorLoop < Loops::AMQP::Bunny
  def process_message(post_url)
    info "Received post url: #{post_url}"
    
    @parser ||= LoopsParser.new

    begin
      @parser.extract_post(post_url)
    rescue StandardError => e
      error "Exception #{e} while parsing post page (#{post_url})."
      e.backtrace.collect {|line| error "\t#{line}" }
    end
    
  end
end
