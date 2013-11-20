class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def matches?(req)
    (req.request_method.downcase.to_sym == self.http_method) && (req.path.match(self.pattern))
  end

  def run(req, res)
    /\/(?<controller>\w+)\/(?<id>\d+)/ =~ req.path # ("/users/1")
    match_data = { controller: controller, action: self.http_method.to_s, id: id }
    @controller_class.new(req, res, match_data).invoke_action(@action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  def draw(&proc)
    self.instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    # add these helpers in a loop here
    define_method(http_method) { |pattern, controller_class, action_name|
                                  add_route(pattern, http_method,
                                  controller_class, action_name) }
  end

  def match(req)
    @routes.each do |route|
      return route if route.matches?(req)
    end
    return nil
  end

  def run(req, res)

    if match(req)
      puts "#{req.path}"
      puts "match(req) => #{match(req)}"
      match(req).run(req,res)
    else
      res.status = 404
      ControllerBase.new(req,res).render_content("404: Not Found", "text/html")
    end
  end
end
