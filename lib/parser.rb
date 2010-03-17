class Parser
  
  ROOT_URL = 'http://mega.genn.org/'
  
  def initialize
    @browser = WWW::Mechanize.new {|a| a.follow_meta_refresh = true }
    @browser.max_history = 2
    @browser.user_agent_alias = 'Linux Mozilla'
    # @browser.set_proxy '127.0.0.1', '8118'
    set_some_cookies
  end

  def set_some_cookies
    cookie = WWW::Mechanize::Cookie.new 'is_bot', "advanced one"
    cookie.path = '/'
    cookie.domain = 'mega.genn.org'

    uri = URI::HTTP.build( :host => 'mega.genn.org', :path => '/')
    @browser.cookie_jar.add uri, cookie
  end

  def extract_posts(link=nil)
    link ||= ROOT_URL
    page = @browser.get(link)
    
    page.search('h2 a.entry-title').each do |a|
      post = Post.find_by_orig_url(a[:href])
      post ||= Post.new
      post.title = a.text
      post.orig_url = a[:href]
      post.content = get_post_body(a)
      post.save
    end
  end
  
  def get_post_body(a)
    post_page = @browser.click(a)
    post_page.at('.content .entry-content').to_s
  end

end
