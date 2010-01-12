require File.join(File.dirname(__FILE__), '..', 'helper')

class IQ::HTMLTest < Test::Unit::TestCase
  context "escape" do
    should "respond" do
      assert_respond_to IQ::HTML, :escape
    end

    should "raise when supplied argument is not a string" do
      not_a_string = stub_everything
      not_a_string.stubs(:is_a?).with(String).returns(false)
      assert_raise(ArgumentError) do
        IQ::HTML.escape(not_a_string)
      end
    end

    should "return value escaped with html entities" do
      assert_equal(
        'Letters, Num83r5, &amp; -- &amp;amp; &gt; -- &amp;gt; &lt; -- &amp;lt; &quot; -- &amp;quot; &amp;#1234;',
        IQ::HTML.escape('Letters, Num83r5, & -- &amp; > -- &gt; < -- &lt; " -- &quot; &#1234;')
      )
    end
  end
  
  context "escape_once" do
    should "escape respond" do
      assert_respond_to IQ::HTML, :escape_once
    end

    should "raise when supplied argument is not a string" do
      not_a_string = stub_everything
      not_a_string.stubs(:is_a?).with(String).returns(false)
      assert_raise(ArgumentError) { IQ::HTML.escape_once(not_a_string) }
    end

    should "return value escaped with html entities ignoring already escaped entities" do
      assert_equal(
        'Letters, Num83r5, &amp; -- &amp; &gt; -- &gt; &lt; -- &lt; &quot; -- &quot; &#1234;',
        IQ::HTML.escape_once('Letters, Num83r5, & -- &amp; > -- &gt; < -- &lt; " -- &quot; &#1234;')
      )
    end
  end
  
  context "sanitize_as_dom_id" do
    should "respond" do
      assert_respond_to IQ::HTML, :sanitize_as_dom_id
    end

    should "accept name argument" do
      assert_nothing_raised(ArgumentError) do
        IQ::HTML.sanitize_as_dom_id('the string')
      end
    end

    should "raise when name is not a string" do
      not_a_string = stub_everything
      not_a_string.stubs(:is_a?).with(String).returns(false)
      assert_raise(ArgumentError) do
        IQ::HTML.sanitize_as_dom_id(not_a_string)
      end
    end

    should "return sanitized name" do
      assert_equal(
        '----LeTTers:--Num83r--B0-7h-Plu5.AnoTh3r',
        IQ::HTML.sanitize_as_dom_id('$&% LeTTers:  Num83r$[B0-7h][Plu5.AnoTh3r]')
      )
    end
  end
  
  context "tag" do
    should "respond" do
      assert_respond_to IQ::HTML, :tag
    end
    
    should "raise when there are too many arguments" do
      assert_raise(ArgumentError) do
        IQ::HTML.tag('strong', 'Hello', { :title => 'Howdy' }, false, stub)
      end
    end

    should "raise when name is not a string or a symbol" do
      not_a_string_or_symbol = stub
      not_a_string_or_symbol.stubs(:is_a?).with(String).returns(false)
      not_a_string_or_symbol.stubs(:is_a?).with(Symbol).returns(false)
      assert_raise(ArgumentError) do
        IQ::HTML.tag(not_a_string_or_symbol)
      end
    end
    
    context "with 2 argument usage" do
      should "raise when 2nd argument is not a string or hash" do
        not_a_string_or_hash = stub
        not_a_string_or_hash.stubs(:is_a?).with(String).returns(false)
        not_a_string_or_hash.stubs(:is_a?).with(Hash).returns(false)
        assert_raise(ArgumentError) { IQ::HTML.tag('the_name', not_a_string_or_hash) }
      end
    end
    
    context "with 3 argument usage" do
      should "raise when 2nd argument is not a string or hash" do
        not_a_string_or_hash = stub
        not_a_string_or_hash.stubs(:is_a?).with(String).returns(false)
        not_a_string_or_hash.stubs(:is_a?).with(Hash).returns(false)
        assert_raise(ArgumentError) { IQ::HTML.tag('the_name', not_a_string_or_hash, stub_everything) }
      end
      
      should "raise when 2nd argument is a string and 3rd argument is not a hash or boolean" do
        not_a_string_or_boolean = stub
        not_a_string_or_boolean.stubs(:is_a?).with(String).returns(false)
        not_a_string_or_boolean.stubs(:==).with(true).returns(false)
        not_a_string_or_boolean.stubs(:==).with(false).returns(false)
        assert_raise(ArgumentError) { IQ::HTML.tag('the_name', 'the content', not_a_string_or_boolean) }
      end
      
      should "raise when 2nd argument is a hash and 3rd argument supplied" do
        assert_raise(ArgumentError) { IQ::HTML.tag('the_name', { :title => 'The title' }, stub_everything) }
      end
      
      should "raise when setting escape to true but not supplying content" do
        assert_raise(ArgumentError) { IQ::HTML.tag('the_name', { :title => 'The title' }, true) }
      end
    end

    context "with 4 argument usage" do
      should "raise when 2nd argument is not a string" do
        not_a_string = stub
        not_a_string.stubs(:is_a?).with(String).returns(false)
        assert_raise(ArgumentError) { IQ::HTML.tag('the_name', not_a_string, { :title => 'Title' }, true) }
      end
      
      should "raise when 3rd argument is not a hash" do
        not_a_hash = stub
        not_a_hash.stubs(:is_a?).with(Hash).returns(false)
        assert_raise(ArgumentError) { IQ::HTML.tag('the_name', 'the content', not_a_hash, true) }
      end
      
      should "raise when 4th argument is not a boolean" do
        not_a_boolean = stub
        not_a_boolean.stubs(:===).with(true).returns(false)
        not_a_boolean.stubs(:===).with(false).returns(false)
        assert_raise(ArgumentError) { IQ::HTML.tag('the_name', 'the content', { :title => 'Title' }, not_a_boolean) }
      end
    end

    should "return self closing tag of specified name" do
      assert_equal '<the_tag />', IQ::HTML.tag('the_tag')
    end

    should "return self closing tag of specified name with attributes when attributes supplied" do
      assert_equal(
        '<the_tag id="foo" name="bar" />',
        IQ::HTML.tag('the_tag', :id => 'foo', :name => 'bar')
      )
    end

    should "return content tag of specified name" do
      assert_equal '<the_tag>the content</the_tag>', 
      IQ::HTML.tag('the_tag', 'the content')
    end

    should "return content tag of specified name with attributes when content and attribute options supplied" do
      assert_equal(
        '<the_tag for="bar" value="foo">the content</the_tag>',
        IQ::HTML.tag('the_tag', 'the content', :value => 'foo', :for => 'bar')
      )
    end

    should "apply attributes in alphabetical order" do
      assert_equal(
        '<the_tag a="foo" b="bar" c="baz" d="yum" />',
        IQ::HTML.tag('the_tag', :a => 'foo', :b => 'bar', :c => 'baz', :d => 'yum')
      )
    end

    should "escape attributes in self closing tag by default" do
      IQ::HTML.stubs(:escape).with('the value').returns('the value [escaped]')
      assert_equal(
        '<the_tag value="the value [escaped]" />',
        IQ::HTML.tag('the_tag', :value => 'the value')
      )
    end

    should "escape attributes in content tag by default" do
      IQ::HTML.stubs(:escape).with('the content').returns('the content [escaped]')
      IQ::HTML.stubs(:escape).with('the value').returns('the value [escaped]')
      assert_equal(
        '<the_tag value="the value [escaped]">the content [escaped]</the_tag>',
        IQ::HTML.tag('the_tag', 'the content', :value => 'the value')
      )
    end

    should "escape attributes in content tag even when escape turned off for content" do
      IQ::HTML.stubs(:escape).with('the value').returns('the value [escaped]')
      assert_equal(
        '<the_tag value="the value [escaped]">the content</the_tag>',
        IQ::HTML.tag('the_tag', 'the content', { :value => 'the value' }, false)
      )
    end

    should "ignore attributes with nil values in self closing tag" do
      assert_equal(
        '<the_tag value="not nil" />',
        IQ::HTML.tag('the_tag', :value => 'not nil', :foo => nil, :bar => nil)
      )     
    end
    
    should "ignore attributes with nil values in content tag" do
      assert_equal(
        '<the_tag value="not nil">the content</the_tag>',
        IQ::HTML.tag('the_tag', 'the content', :value => 'not nil', :foo => nil, :bar => nil)
      )     
    end
    
    should "stringify attributes in self closing tag" do
      assert_equal(
        '<the_tag name="321" value="a_symbol" />',
        IQ::HTML.tag('the_tag', :name => 321, :value => :a_symbol)
      )     
    end
    
    should "stringify attributes in content tag" do
      assert_equal(
        '<the_tag name="321" value="a_symbol">the content</the_tag>',
        IQ::HTML.tag('the_tag', 'the content', :name => 321, :value => :a_symbol)
      )     
    end
    
    should "escape content by default" do
      IQ::HTML.stubs(:escape).with('the content').returns('the content [escaped]')
      assert_equal('<the_tag>the content [escaped]</the_tag>', IQ::HTML.tag('the_tag', 'the content'))
    end

    should "escape content when escape option is true" do
      IQ::HTML.stubs(:escape).with('the content').returns('the content [escaped]')
      assert_equal(
        '<the_tag>the content [escaped]</the_tag>', IQ::HTML.tag('the_tag', 'the content', true)
      )
    end
    
    should "not escape content when escape option is false" do
      IQ::HTML.stubs(:escape).with('the content').returns('the content [escaped]')
      assert_equal(
        '<the_tag>the content</the_tag>', IQ::HTML.tag('the_tag', 'the content', false)
      )
    end
  end
end