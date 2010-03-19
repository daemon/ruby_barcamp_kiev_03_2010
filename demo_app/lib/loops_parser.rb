class LoopsParser < Parser
  
  attr_accessor :bunny, :exchange, :queues
  
  def initialize
    super
    prepare_mq
  end

  def find_posts(page_url, &block)
    page = @browser.get(page_url)

    page.search('h2 a.entry-title').each do |a|
      yield a[:href]
    end
  end    
  
  def extract_post(post_url)
    post = Post.find_by_orig_url(post_url)
    post ||= Post.new

    page = @browser.get(post_url)

    post.title = page.at('h2 a.entry-title').text
    post.orig_url = post_url
    post.content = page.at('.content .entry-content').to_s
    post.dots = grab_dotted_pattern(page.body.to_s)

    post.save
  end
  
  def prepare_mq
    @config = YAML.load(ERB.new(File.read(File.join(RAILS_ROOT, 'config/loops.yml'))).result)
    @bunny = Bunny.new(@config['generic_loop']['connection'].symbolize_keys)
    @bunny.start
    
    @queues = {}
    @exchange = @bunny.exchange @config['generic_loop']['exchange'], :type => :topic, :durable => true
    @config['loops'].keys.each do |loop_name|
      @queues[loop_name.to_sym] = @bunny.queue loop_name, :durable => true
      @queues[loop_name.to_sym].bind(@exchange, :key => @config['loops'][loop_name]['key'])
    end
  end
end