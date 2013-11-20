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
    @contoller_class.new(req, res).invoke_action(@action_name)
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
  end

  def run(req, res)
    puts "@Routes::: #{@routes}".inspect
    if match(req)
      puts "match(req)::: #{match(req)}".inspect
      puts "match(req) is a: #{match(req).class}"
      puts "first element: #{match(req).first}"
      match(req).run(req,res)
    else
      ControllerBase.new.render("error", "text/html")
    end
  end
end
