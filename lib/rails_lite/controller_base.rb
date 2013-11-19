require 'erb'
require_relative 'params'
require_relative 'session'

class ControllerBase
  attr_reader :params
  attr_accessor :session

  def initialize(req, res, route_params = { })
    @request  = req
    @response = res
    @params   = Params.new(@request)
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    puts "This is the request: #{@request}"
    puts "This is the request body: #{@request.body}"
  end

  def session
    @session ||= Session.new(@request)
  end

  def already_rendered?
  end

  def redirect_to(url)
    self.session.store_session(@response)
    @response.set_redirect(WEBrick::HTTPStatus::TemporaryRedirect, url)
    @already_built_response = true
  end

  def render_content(content, type)
    self.session.store_session(@response)
    @response.body = content
    @response.content_type = type
    @already_built_response = true
  end

  def render(template_name)
    file = File.read("views/#{self.class.to_s.underscore}/#{template_name}.html.erb")
    template = ERB.new(file).result(binding)

    render_content(template, "text/html")
  end

  def invoke_action(name)
  end


end

