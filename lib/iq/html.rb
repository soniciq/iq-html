module IQ
  module HTML    
    HTML_ESCAPE	=	{ '&' => '&amp;', '>' => '&gt;', '<' => '&lt;', '"' => '&quot;' }.freeze
    
    # Returns HTML escaped version of supplied string.
    # 
    # @example
    #   IQ::HTML.escape('Letters, Num83r5, & -- &amp; > -- &gt; < -- &lt; " -- &quot; &#1234;')
    #   #=> 'Letters, Num83r5, &amp; -- &amp;amp; &gt; -- &amp;gt; &lt; -- &amp;lt; &quot; -- &amp;quot; &amp;#1234;'
    # 
    # @param [String]
    # @return [String] the escaped string
    def self.escape(value)
      raise ArgumentError, 'Must supply a string' unless value.is_a?(String)
      value.gsub(/[&"><]/) { |special| HTML_ESCAPE[special] }
    end
  
    # Returns HTML escaped version of supplied string leaving any existing
    # entities intact.
    # 
    # @example
    #   IQ::HTML.escape_once('Letters, Num83r5, & -- &amp; > -- &gt; < -- &lt; " -- &quot; &#1234;')
    #   #=> 'Letters, Num83r5, &amp; -- &amp; &gt; -- &gt; &lt; -- &lt; &quot; -- &quot; &#1234;'
    #
    # @param [String]
    # @return [String] the escaped string (with existing entities intact)
    def self.escape_once(value)
      raise ArgumentError, 'Must supply a string' unless value.is_a?(String)
      value.gsub(/[\"><]|&(?!([a-zA-Z]+|(#\d+));)/) { |special| HTML_ESCAPE[special] }
    end
    
    # Takes a string and returns a new hyphenated string that can safely be
    # used as a dom id.
    #
    # @example
    #   IQ::HTML.sanitize_as_dom_id('product[variants][0][stock]')
    #   #=> 'product-variants-0-stock'
    # 
    # @param [String]
    # @return [String] the escaped string (leaving existing entities intact)
    def self.sanitize_as_dom_id(string_to_sanitize)
      raise ArgumentError, 'Argument must be a string' unless string_to_sanitize.is_a?(String)
      # see http://www.w3.org/TR/html4/types.html#type-name
      string_to_sanitize.to_s.gsub(']','').gsub(/[^-a-zA-Z0-9:.]/, "-")
    end
    
    # Helper method for creating HTML tags of a specified name, along with
    # optional content and list of attributes. All attribute values and content
    # will be escaped, however content escaping may be dissabled by supplying
    # +false+ as the last argument.
    #
    # @example
    #   IQ::HTML.tag('br')                                      #=> "<br />"
    #   IQ::HTML.tag('strong', 'Bill & Ben')                    #=> "<strong>Bill &amp; Ben</strong>"
    #   IQ::HTML.tag('strong', 'Bill & Ben', false)             #=> "<strong>Bill & Ben</strong>"
    #   IQ::HTML.tag('strong', 'B&B', { :id => 'bb' }, false)   #=> "<strong id="bb">Bill & Ben</strong>"
    #   IQ::HTML.tag('input', :title => 'B&B')                  #=> '<input type="text" title="B&amp;B" />'
    #   IQ::HTML.tag('strong', 'B&B', :title => 'Bill & Ben')   #=> "<strong title="Bill &amp; Ben">B&amp;B</strong>"
    # 
    # @overload self.tag(name, attributes = {})
    #   @param [String, Symbol] name
    #   @param [Hash] attributes
    # @overload self.tag(name, content, escape = true)
    #   @param [String, Symbol] name
    #   @param [String] content
    #   @param [true, false] escape
    # @overload self.tag(name, content, attributes, escape = true)
    #   @param [String, Symbol] name
    #   @param [String] content
    #   @param [Hash] attributes
    #   @param [true, false] escape
    #
    # @return [String]
    def self.tag(name, *args)
      raise ArgumentError, 'Name must be a symbol or string' unless name.is_a?(Symbol) || name.is_a?(String)

      case args.size
        when 3 then content, attributes, escape = *args
        when 2
          case args.last
            when Hash then escape, content, attributes = true, *args
            when true, false then content, escape = *args
            else
              raise ArgumentError, 'Third argument must be an attribute hash or boolean escape value'
          end
        when 1
          case args.last
            when String then escape, content = true, *args
            when Hash then attributes = args.last
            else
              raise ArgumentError, 'Second argument must be a content string or an attributes hash'
          end
        when 0
        else
          raise ArgumentError, "Too many arguments"
      end
      
      raise ArgumentError, 'Content must be in the form of a string' unless content.nil? || content.is_a?(String)
      raise ArgumentError, 'Attributes must be in the form of a hash' unless attributes.nil? || attributes.is_a?(Hash)
      raise ArgumentError, 'Escape argument must be a boolean' unless escape.nil? || escape == true || escape == false
      raise ArgumentError, 'Escape option supplied, but no content to escape' if escape && content.nil?

      tag = "<#{name}"
      if attributes
        attributes.reject! { |key, value| value.nil? }
        tag << attributes.map { |key, value| %( #{key}="#{escape(value.to_s)}") }.sort.join
      end
      tag << (content ? ">#{escape ? escape(content) : content}</#{name}>" : ' />')
    end
  end
end