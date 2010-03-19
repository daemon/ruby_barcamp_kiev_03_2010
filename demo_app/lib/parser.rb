class Parser
  
  ROOT_URL = 'http://mega.genn.org/'
  
  def initialize
    @browser = Mechanize.new {|a| a.follow_meta_refresh = true }
    @browser.max_history = 2
    @browser.user_agent_alias = 'Linux Mozilla'
    # @browser.set_proxy '127.0.0.1', '8118'
    set_some_cookies
  end

  def set_some_cookies
    cookie = Mechanize::Cookie.new 'is_bot', "advanced one"
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
      
      post_page = @browser.click(a)
      
      post.title = a.text
      post.orig_url = a[:href]
      post.content = post_page.at('.content .entry-content').to_s
      
      post.dots = grab_dotted_pattern(post_page.body.to_s)
      
      post.save
    end
  end
  
  def grab_dotted_pattern(html)
    js_page = Harmony::Page.new html
    js_page.load(File.join(RAILS_ROOT, 'assets/jquery-1.4.2.min.js'))
    asciify_dots(js_page.execute_js("$('.mclrs').html()"))
  end
  
  def asciify_dots(html)
    html.strip!
    html.gsub!(/<script>.*<\/script>/m, '')
    html.gsub!('<div class="mdt"></div>', ' ')
    html.gsub!('<div class="mrdt"></div>', '.')
    html.gsub!(/<div class="mclr" .*?>(.*)<\/div>/, "\\1\n")
    html.gsub!(/\n+/, "\n")
    html
  end

end
