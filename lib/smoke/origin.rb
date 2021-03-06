module Smoke
  class Origin
    attr_reader :items, :name
    
    def initialize(name, &block)
      raise StandardError, "Sources must have a name" unless name
      @name = name
      @items = []
      activate!
      instance_eval(&block) if block_given?
    end
    
    # Output your items in a range of formats (:ruby, :json and :yaml currently)
    # Ruby is the default format and will automagically yielded from your source
    #
    # Usage
    # 
    #   output(:json)
    #   => "[{title: \"Ray\"}, {title: \"Peace\"}]"
    def output(type = :ruby)
      dispatch if respond_to? :dispatch
      output = (@items.length == 1) ? @items.first : @items
      
      case type
      when :ruby
        return output
      when :json
        return ::JSON.generate(output)
      when :yaml
        return YAML.dump(output)
      end
    end
    
    def items=(items) # :nodoc:
      @items = items.flatten.map{|i| i.symbolize_keys! }
      invoke_transformations
    end
    
    # Transform each item
    #
    # Usage:
    #   emit do
    #     rename(:href => :link)
    #   end 
    def emit(&block)
      (@transformations ||= []) << DelayedBlock.new(&block)
    end

    # Re-sort items by a particular key
    def sort(key)
      @items = @items.sort_by{|i| i[key] }
    rescue NoMethodError => e
      Smoke.log.info "You're trying to sort by \"#{key}\" but it does not exist in your item set"
    ensure
      return self
    end

    # Keep items that match the regex
    # 
    # Usage (chained): 
    #     Smoke[:ruby].keep(:title, /tuesday/i)
    # Usage (block, during initialization):
    #     Smoke.yql(:ruby) do
    #       ...
    #       keep(:title, /tuesday/i)
    #     end
    def keep(key, matcher)
      @items.reject! {|i| (i[key] =~ matcher) ? false : true }
      return self
    end

    # Discard items that do not match the regex
    # 
    # Usage (chained): 
    #     Smoke[:ruby].discard(:title, /tuesday/i)
    # Usage (block, during initialization):
    #     Smoke.yql(:ruby) do
    #       ...
    #       discard(:title, /tuesday/i)
    #     end
    def discard(key, matcher)
      @items.reject! {|i| (i[key] =~ matcher) ? true : false }
      return self
    end

    # Rename one or many keys at a time
    # Suggested that you run it within an each block, but it makes no difference
    # other than readability
    #
    # Usage
    #   # Renames all items with a key of href to link
    #   rename(:href => :link)
    # or
    #   rename(:href => :link, :description => :excerpt)
    def rename(*args)
      @items.each {|item| item.rename(*args) }
      return self
    end

    # Truncate your result set to this many objects
    #
    # Usage
    #
    #   truncate(3).output
    #   => [{title => "Canon"}, {:title => "Nikon"}, {:title => "Pentax"}]
    def truncate(length)
      @items = @items[0..(length - 1)]
      return self
    end
    
    private
    def invoke_transformations
      @transformations.each{|t| t.execute! } unless @transformations.nil?
    end
    
    def activate!
      Smoke.activate(name, self)
    end
  end
end

Dir["#{File.dirname(__FILE__)}/source/*.rb"].each &method(:require)