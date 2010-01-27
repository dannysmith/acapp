# DO NOT MODIFY THIS FILE
module Bundler
 file = File.expand_path(__FILE__)
 dir = File.dirname(file)

  ENV["PATH"]     = "#{dir}/../../../../bin:#{ENV["PATH"]}"
  ENV["RUBYOPT"]  = "-r#{file} #{ENV["RUBYOPT"]}"

  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/shorturl-0.8.7/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/shorturl-0.8.7/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/json_pure-1.2.0/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/json_pure-1.2.0/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/chronic-0.2.3/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/chronic-0.2.3/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/extlib-0.9.14/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/extlib-0.9.14/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rack-1.1.0/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rack-1.1.0/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rack-flash-0.1.1/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rack-flash-0.1.1/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/sinatra-0.9.4/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/sinatra-0.9.4/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/dm-timestamps-0.10.2/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/dm-timestamps-0.10.2/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rubyforge-2.0.3/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rubyforge-2.0.3/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/crack-0.1.4/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/crack-0.1.4/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rake-0.8.7/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rake-0.8.7/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/gemcutter-0.3.0/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/gemcutter-0.3.0/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/hoe-2.5.0/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/hoe-2.5.0/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/addressable-2.1.1/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/addressable-2.1.1/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/dm-core-0.10.2/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/dm-core-0.10.2/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/dm-validations-0.10.2/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/dm-validations-0.10.2/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/haml-2.3.0/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/haml-2.3.0/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/httparty-0.5.0/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/httparty-0.5.0/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/mustache-0.5.1/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/mustache-0.5.1/lib")

  @gemfile = "#{dir}/../../../../Gemfile"

  require "rubygems" unless respond_to?(:gem) # 1.9 already has RubyGems loaded

  @bundled_specs = {}
  @bundled_specs["shorturl"] = eval(File.read("#{dir}/specifications/shorturl-0.8.7.gemspec"))
  @bundled_specs["shorturl"].loaded_from = "#{dir}/specifications/shorturl-0.8.7.gemspec"
  @bundled_specs["json_pure"] = eval(File.read("#{dir}/specifications/json_pure-1.2.0.gemspec"))
  @bundled_specs["json_pure"].loaded_from = "#{dir}/specifications/json_pure-1.2.0.gemspec"
  @bundled_specs["chronic"] = eval(File.read("#{dir}/specifications/chronic-0.2.3.gemspec"))
  @bundled_specs["chronic"].loaded_from = "#{dir}/specifications/chronic-0.2.3.gemspec"
  @bundled_specs["extlib"] = eval(File.read("#{dir}/specifications/extlib-0.9.14.gemspec"))
  @bundled_specs["extlib"].loaded_from = "#{dir}/specifications/extlib-0.9.14.gemspec"
  @bundled_specs["rack"] = eval(File.read("#{dir}/specifications/rack-1.1.0.gemspec"))
  @bundled_specs["rack"].loaded_from = "#{dir}/specifications/rack-1.1.0.gemspec"
  @bundled_specs["rack-flash"] = eval(File.read("#{dir}/specifications/rack-flash-0.1.1.gemspec"))
  @bundled_specs["rack-flash"].loaded_from = "#{dir}/specifications/rack-flash-0.1.1.gemspec"
  @bundled_specs["sinatra"] = eval(File.read("#{dir}/specifications/sinatra-0.9.4.gemspec"))
  @bundled_specs["sinatra"].loaded_from = "#{dir}/specifications/sinatra-0.9.4.gemspec"
  @bundled_specs["dm-timestamps"] = eval(File.read("#{dir}/specifications/dm-timestamps-0.10.2.gemspec"))
  @bundled_specs["dm-timestamps"].loaded_from = "#{dir}/specifications/dm-timestamps-0.10.2.gemspec"
  @bundled_specs["rubyforge"] = eval(File.read("#{dir}/specifications/rubyforge-2.0.3.gemspec"))
  @bundled_specs["rubyforge"].loaded_from = "#{dir}/specifications/rubyforge-2.0.3.gemspec"
  @bundled_specs["crack"] = eval(File.read("#{dir}/specifications/crack-0.1.4.gemspec"))
  @bundled_specs["crack"].loaded_from = "#{dir}/specifications/crack-0.1.4.gemspec"
  @bundled_specs["rake"] = eval(File.read("#{dir}/specifications/rake-0.8.7.gemspec"))
  @bundled_specs["rake"].loaded_from = "#{dir}/specifications/rake-0.8.7.gemspec"
  @bundled_specs["gemcutter"] = eval(File.read("#{dir}/specifications/gemcutter-0.3.0.gemspec"))
  @bundled_specs["gemcutter"].loaded_from = "#{dir}/specifications/gemcutter-0.3.0.gemspec"
  @bundled_specs["hoe"] = eval(File.read("#{dir}/specifications/hoe-2.5.0.gemspec"))
  @bundled_specs["hoe"].loaded_from = "#{dir}/specifications/hoe-2.5.0.gemspec"
  @bundled_specs["addressable"] = eval(File.read("#{dir}/specifications/addressable-2.1.1.gemspec"))
  @bundled_specs["addressable"].loaded_from = "#{dir}/specifications/addressable-2.1.1.gemspec"
  @bundled_specs["dm-core"] = eval(File.read("#{dir}/specifications/dm-core-0.10.2.gemspec"))
  @bundled_specs["dm-core"].loaded_from = "#{dir}/specifications/dm-core-0.10.2.gemspec"
  @bundled_specs["dm-validations"] = eval(File.read("#{dir}/specifications/dm-validations-0.10.2.gemspec"))
  @bundled_specs["dm-validations"].loaded_from = "#{dir}/specifications/dm-validations-0.10.2.gemspec"
  @bundled_specs["haml"] = eval(File.read("#{dir}/specifications/haml-2.3.0.gemspec"))
  @bundled_specs["haml"].loaded_from = "#{dir}/specifications/haml-2.3.0.gemspec"
  @bundled_specs["httparty"] = eval(File.read("#{dir}/specifications/httparty-0.5.0.gemspec"))
  @bundled_specs["httparty"].loaded_from = "#{dir}/specifications/httparty-0.5.0.gemspec"
  @bundled_specs["mustache"] = eval(File.read("#{dir}/specifications/mustache-0.5.1.gemspec"))
  @bundled_specs["mustache"].loaded_from = "#{dir}/specifications/mustache-0.5.1.gemspec"

  def self.add_specs_to_loaded_specs
    Gem.loaded_specs.merge! @bundled_specs
  end

  def self.add_specs_to_index
    @bundled_specs.each do |name, spec|
      Gem.source_index.add_spec spec
    end
  end

  add_specs_to_loaded_specs
  add_specs_to_index

  def self.require_env(env = nil)
    context = Class.new do
      def initialize(env) @env = env && env.to_s ; end
      def method_missing(*) ; yield if block_given? ; end
      def only(*env)
        old, @only = @only, _combine_only(env.flatten)
        yield
        @only = old
      end
      def except(*env)
        old, @except = @except, _combine_except(env.flatten)
        yield
        @except = old
      end
      def gem(name, *args)
        opt = args.last.is_a?(Hash) ? args.pop : {}
        only = _combine_only(opt[:only] || opt["only"])
        except = _combine_except(opt[:except] || opt["except"])
        files = opt[:require_as] || opt["require_as"] || name
        files = [files] unless files.respond_to?(:each)

        return unless !only || only.any? {|e| e == @env }
        return if except && except.any? {|e| e == @env }

        if files = opt[:require_as] || opt["require_as"]
          files = Array(files)
          files.each { |f| require f }
        else
          begin
            require name
          rescue LoadError
            # Do nothing
          end
        end
        yield if block_given?
        true
      end
      private
      def _combine_only(only)
        return @only unless only
        only = [only].flatten.compact.uniq.map { |o| o.to_s }
        only &= @only if @only
        only
      end
      def _combine_except(except)
        return @except unless except
        except = [except].flatten.compact.uniq.map { |o| o.to_s }
        except |= @except if @except
        except
      end
    end
    context.new(env && env.to_s).instance_eval(File.read(@gemfile), @gemfile, 1)
  end
end

module Gem
  @loaded_stacks = Hash.new { |h,k| h[k] = [] }

  def source_index.refresh!
    super
    Bundler.add_specs_to_index
  end
end
