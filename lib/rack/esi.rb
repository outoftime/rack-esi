require "rack"
require "hpricot"

class Rack::ESI
  class Error < ::RuntimeError
  end

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, unprocessed_body = original_response = @app.call(env)

    return original_response unless status.to_i == 200
    return original_response unless headers["Content-Type"].to_s.match(/(ht|x)ml/) # FIXME: Use another pattern

    body = process_body(unprocessed_body)

    return original_response unless body.include?("<esi:") 

    xml = Hpricot.XML(body)

    xml.search("esi:include") do |include_element|
      if src = include_element["src"]
        path_info = src                                  # TODO: Rewrite the URL to allow more than absolute paths
        inclusion_env = env.merge("PATH_INFO" => src)    # TODO: Do something with SCRIPT_NAME/REQUEST_PATH/REQUEST_URI
        data = process_body(@app.call(inclusion_env)[2]) # FIXME: Check the status
        new_element = Hpricot::Text.new(data)
        include_element.parent.replace_child(include_element, new_element)
      else
        raise XMLIncluder::Error, "<esi:include .../> element without @src"
      end
    end

    # TODO
    # xml.search("esi:remove") do |remove_element|
    # 
    # end

    [status, headers, [xml.to_s]]
  end
  
  private
  
  def process_body(unprocessed_body)
    body = ""
    unprocessed_body.each { |part| body << part }
    return body
  end
end