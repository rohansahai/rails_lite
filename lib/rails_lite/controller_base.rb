require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'
require_relative 'flash'

class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(req, route_params)
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    if already_built_response?
      raise "You already rendered"
    else
      @res.content_type = type
      @res.body = content
      @already_built_response = true
      self.session.store_session(@res)
    end
  end

  # helper method to alias @already_built_response
  def already_built_response?
    @already_built_response ||= false
  end

  # set the response status code and header
  def redirect_to(url)
    if already_built_response?
      raise "You already rendered"
    else
      @res.status = 302
  	  @res["Location"] = url
      self.session.store_session(@res)
      self.flash.store_flash(@res)
      @already_built_response = true
    end
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    template = File.read("views/#{self.class.to_s.underscore}/#{template_name}.html.erb")
    compiled_template = ERB.new(template)
	  b = binding()
	  render_content(compiled_template.result(b), "text/html")
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end
  
  # method exposing a 'Flash' object
  def flash
    @flash ||= Flash.new(@req)
  end
  
  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    render(name) unless already_built_response?
  end
end
