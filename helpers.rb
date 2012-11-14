class Array #:nodoc:
  # Method added in Rails rev 7217
  def extract_options!
    last.is_a?(::Hash) ? pop : {}
  end unless defined? Array.new.extract_options!
end

module Sinatra
  module Sprockets
    module Helpers
      BOOLEAN_ATTRIBUTES = %w(disabled readonly multiple checked autobuffer
                           autoplay controls loop selected hidden scoped async
                           defer reversed ismap seemless muted required
                           autofocus novalidate formnovalidate open pubdate).to_set
      BOOLEAN_ATTRIBUTES.merge(BOOLEAN_ATTRIBUTES.map {|attribute| attribute.to_sym })
      
      
      def javascript_include_tag(app, *sources)
        sprockets = Circular.sprockets[app]
        options = sources.extract_options!
        debug = options.delete(:debug)
        body  = options.delete(:body)
        digest  = options.delete(:digest)

        sources.collect do |source|
          asset = sprockets[source]
          if debug
            asset.to_a.map { |dep|
              src = app.to_s + "/" + dep.logical_path
              content_tag("script", "", { "type" => "application/javascript", "src" => src }.merge!(options))
            }
          else
            src = app.to_s + "/" + asset.logical_path
            content_tag("script", "", { "type" => "application/javascript", "src" => src }.merge!(options))
          end
        end.join("\n")
      end

      def stylesheet_link_tag(app, *sources)
        sprockets = Circular.sprockets[app]
        options = sources.extract_options!
        debug = options.delete(:debug)
        body  = options.delete(:body)
        digest  = options.delete(:digest)

        sources.collect do |source|
          asset = sprockets[source]
          if debug
            asset.to_a.map { |dep|
              href = app.to_s + "/" + dep.logical_path
              tag("link", { "rel" => "stylesheet", "type" => "text/css", "media" => "screen", "href" => href }.merge!(options))

            }
          else
            href = app.to_s + "/" + asset.logical_path
            tag("link", { "rel" => "stylesheet", "type" => "text/css", "media" => "screen", "href" => href }.merge!(options))

          end
        end.join("\n")
      end


=begin      
      def stylesheet_link_tag(*sources)
        options = sources.extract_options!
        debug   = options.delete(:debug)
        body    = options.delete(:body)
        digest  = options.delete(:digest)
        
        sources.collect do |source|
          if debug && asset = asset_paths.asset_for(source, 'css')
            asset.to_a.map { |dep|
              href = asset_path(dep, :ext => 'css', :body => true, :protocol => :request, :digest => digest)
              tag("link", { "rel" => "stylesheet", "type" => "text/css", "media" => "screen", "href" => href }.merge!(options))
            }
          else
            href = asset_path(source, :ext => 'css', :body => body, :protocol => :request, :digest => digest)
            tag("link", { "rel" => "stylesheet", "type" => "text/css", "media" => "screen", "href" => href }.merge!(options))
          end
        end.join("\n")
      end
=end    

      def tag(name, options = nil, open = false, escape = true)
        "<#{name}#{tag_options(options, escape) if options}#{open ? ">" : " />"}"
        
      end
    
      def content_tag(name, content_or_options_with_block = nil, options = nil, escape = true, &block)
        if block_given?
          options = content_or_options_with_block if content_or_options_with_block.is_a?(Hash)
          content_tag_string(name, block.call, options, escape)
        else
          content_tag_string(name, content_or_options_with_block, options, escape)
        end
      end
    
      def tag_options(options, escape = true)
        unless options.nil?
          attrs = []
          options.each_pair do |key, value|
            if key.to_s == 'data' && value.is_a?(Hash)
              value.each do |k, v|
                if !v.is_a?(String) && !v.is_a?(Symbol)
                  v = v.to_json
                end
                v = ERB::Util.html_escape(v) if escape
                attrs << %(data-#{k.to_s.dasherize}="#{v}")
              end
            elsif BOOLEAN_ATTRIBUTES.include?(key)
              attrs << %(#{key}="#{key}") if value
            elsif !value.nil?
              final_value = value.is_a?(Array) ? value.join(" ") : value
              final_value = ERB::Util.html_escape(final_value) if escape
              attrs << %(#{key}="#{final_value}")
            end
          end
          " #{attrs.sort * ' '}" unless attrs.empty?
        end
      end
    
      def content_tag_string(name, content, options, escape = true)
        tag_options = tag_options(options, escape) if options
        "<#{name}#{tag_options}>#{escape ? ERB::Util.h(content) : content}</#{name}>"
      end
    end
  end
end
