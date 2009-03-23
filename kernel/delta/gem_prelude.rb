# vim: filetype=ruby
# THIS FILE WAS AUTOGENERATED, DO NOT EDIT

if Object.const_defined?(:Gem)

  module Kernel

    def gem(gem_name, *version_requirements)
      Gem.push_gem_version_on_load_path(gem_name, *version_requirements)
    end

  end

  module Gem

    ConfigMap = {
      :sitedir => RbConfig::CONFIG["sitedir"],
      :ruby_version => RbConfig::CONFIG["ruby_version"],
      :libdir => RbConfig::CONFIG["libdir"],
      :sitelibdir => RbConfig::CONFIG["sitelibdir"],
      :arch => RbConfig::CONFIG["arch"],
      :bindir => RbConfig::CONFIG["bindir"],
      :EXEEXT => RbConfig::CONFIG["EXEEXT"],
      :RUBY_SO_NAME => RbConfig::CONFIG["RUBY_SO_NAME"],
      :ruby_install_name => RbConfig::CONFIG["ruby_install_name"]
    }

    def self.dir
      @gem_home ||= nil
      set_home(ENV['GEM_HOME'] || default_dir) unless @gem_home
      @gem_home
    end

    def self.path
      @gem_path ||= nil
      unless @gem_path
        paths = [ENV['GEM_PATH']]
        paths << APPLE_GEM_HOME if defined? APPLE_GEM_HOME
        set_paths(paths.compact.join(File::PATH_SEPARATOR))
      end
      @gem_path
    end

    def self.post_install(&hook)
      @post_install_hooks << hook
    end

    def self.post_uninstall(&hook)
      @post_uninstall_hooks << hook
    end

    def self.pre_install(&hook)
      @pre_install_hooks << hook
    end

    def self.pre_uninstall(&hook)
      @pre_uninstall_hooks << hook
    end

    def self.set_home(home)
      @gem_home = home
      ensure_gem_subdirectories(@gem_home)
    end

    def self.set_paths(gpaths)
      if gpaths
        @gem_path = gpaths.split(File::PATH_SEPARATOR)
        @gem_path << Gem.dir
      else
        @gem_path = [Gem.dir]
      end
      @gem_path.uniq!
      @gem_path.each do |gp| ensure_gem_subdirectories(gp) end
    end

    def self.ensure_gem_subdirectories(path)
    end

  
    @post_install_hooks   ||= []
    @post_uninstall_hooks ||= []
    @pre_uninstall_hooks  ||= []
    @pre_install_hooks    ||= []
  
    ##
    # An Array of the default sources that come with RubyGems
  
    def self.default_sources
      %w[http://gems.rubyforge.org/]
    end
  
    ##
    # Default home directory path to be used if an alternate value is not
    # specified in the environment
  
    def self.default_dir
      if defined? RUBY_FRAMEWORK_VERSION then
        File.join File.dirname(ConfigMap[:sitedir]), 'Gems',
                  ConfigMap[:ruby_version]
      elsif RUBY_VERSION > '1.9' then
        File.join(ConfigMap[:libdir], ConfigMap[:ruby_install_name], 'gems',
                  ConfigMap[:ruby_version])
      else
        File.join(ConfigMap[:libdir], ruby_engine, 'gems',
                  ConfigMap[:ruby_version])
      end
    end
  
    ##
    # Path for gems in the user's home directory
  
    def self.user_dir
      File.join(Gem.user_home, '.gem', ruby_engine,
                ConfigMap[:ruby_version])
    end
  
    ##
    # Default gem load path
  
    def self.default_path
      [user_dir, default_dir]
    end
  
    ##
    # Deduce Ruby's --program-prefix and --program-suffix from its install name
  
    def self.default_exec_format
      baseruby = ConfigMap[:BASERUBY] || 'ruby'
      ConfigMap[:RUBY_INSTALL_NAME].sub(baseruby, '%s') rescue '%s'
    end
  
    ##
    # The default directory for binaries
  
    def self.default_bindir
      if defined? RUBY_FRAMEWORK_VERSION then # mac framework support
        '/usr/bin'
      else # generic install
        ConfigMap[:bindir]
      end
    end
  
    ##
    # The default system-wide source info cache directory
  
    def self.default_system_source_cache_dir
      File.join Gem.dir, 'source_cache'
    end
  
    ##
    # The default user-specific source info cache directory
  
    def self.default_user_source_cache_dir
      File.join Gem.user_home, '.gem', 'source_cache'
    end
  
    ##
    # A wrapper around RUBY_ENGINE const that may not be defined
  
    def self.ruby_engine
      if defined? RUBY_ENGINE then
        RUBY_ENGINE
      else
        'ruby'
      end
    end
  
  

    # Methods before this line will be removed when QuickLoader is replaced
    # with the real RubyGems

    GEM_PRELUDE_METHODS = Gem.methods(false)

    begin
      verbose, debug = $VERBOSE, $DEBUG
      $VERBOSE = $DEBUG = nil

      begin
        require 'rubygems/defaults/operating_system'
      rescue LoadError
      end

      if defined?(RUBY_ENGINE) then
        begin
          require "rubygems/defaults/#{RUBY_ENGINE}"
        rescue LoadError
        end
      end
    ensure
      $VERBOSE, $DEBUG = verbose, debug
    end

    module QuickLoader

      def self.load_full_rubygems_library
        class << Gem
          Gem::GEM_PRELUDE_METHODS.each do |method_name|
            undef_method method_name
          end
        end

        Kernel.module_eval do
          undef_method :gem if method_defined? :gem
        end

        $".delete File.join(Gem::ConfigMap[:libdir],
                            Gem::ConfigMap[:ruby_install_name],
                            Gem::ConfigMap[:ruby_version], 'rubygems.rb')

        require 'rubygems'
      end

      GemPaths = {}
      GemVersions = {}

      def push_gem_version_on_load_path(gem_name, *version_requirements)
        if version_requirements.empty?
          unless GemPaths.has_key?(gem_name)
            raise LoadError.new("Could not find RubyGem #{gem_name} (>= 0)\n")
          end

          # highest version gems already active
          return false
        else
          if version_requirements.length > 1
            QuickLoader.load_full_rubygems_library
            return gem(gem_name, *version_requirements)
          end

          requirement, version = version_requirements[0].split
          requirement.strip!

          if requirement == ">" || requirement == ">="
            if (GemVersions[gem_name] <=> Gem.calculate_integers_for_gem_version(version)) >= 0
              return false
            end
          elsif requirement == "~>"
            loaded_version = GemVersions[gem_name]
            required_version = Gem.calculate_integers_for_gem_version(version)
            if loaded_version && (loaded_version[0] == required_version[0])
              return false
            end
          end

          QuickLoader.load_full_rubygems_library
          gem(gem_name, *version_requirements)
        end
      end

      def calculate_integers_for_gem_version(gem_version)
        numbers = gem_version.split(".").collect {|n| n.to_i}
        numbers.pop while numbers.last == 0
        numbers << 0 if numbers.empty?
        numbers
      end

      def push_all_highest_version_gems_on_load_path
        Gem.path.each do |path|
          gems_directory = File.join(path, "gems")
          if File.exist?(gems_directory)
            Dir.entries(gems_directory).each do |gem_directory_name|
              next if gem_directory_name == "." || gem_directory_name == ".."
              dash = gem_directory_name.rindex("-")
              next if dash.nil?
              gem_name = gem_directory_name[0...dash]
              current_version = GemVersions[gem_name]
              new_version = calculate_integers_for_gem_version(gem_directory_name[dash+1..-1])
              if current_version
                if (current_version <=> new_version) == -1
                  GemVersions[gem_name] = new_version
                  GemPaths[gem_name] = File.join(gems_directory, gem_directory_name)
                end
              else
                GemVersions[gem_name] = new_version
                GemPaths[gem_name] = File.join(gems_directory, gem_directory_name)
              end
            end
          end
        end

        require_paths = []

        GemPaths.each_value do |path|
          if File.exist?(file = File.join(path, ".require_paths")) then
            paths = File.read(file).split.map do |require_path|
              File.join path, require_path
            end

            require_paths.concat paths
          else
            require_paths << file if File.exist?(file = File.join(path, "bin"))
            require_paths << file if File.exist?(file = File.join(path, "lib"))
          end
        end

        # "tag" the first require_path inserted into the $LOAD_PATH to enable
        # indexing correctly with rubygems proper when it inserts an explicitly
        # gem version
        unless require_paths.empty?
          require_paths.first.instance_variable_set(:@gem_prelude_index, true)
        end
        # gem directories must come after -I and ENV['RUBYLIB']
        $:[$:.index(ConfigMap[:sitelibdir]),0] = require_paths
      end

      def const_missing(constant)
        QuickLoader.load_full_rubygems_library
        if Gem.const_defined?(constant)
          Gem.const_get(constant)
        else
          super
        end
      end

      def method_missing(method, *args, &block)
        QuickLoader.load_full_rubygems_library
        super unless Gem.respond_to?(method)
        Gem.send(method, *args, &block)
      end
    end

    extend QuickLoader

  end

  begin
    Gem.push_all_highest_version_gems_on_load_path
    $" << File.join(Gem::ConfigMap[:libdir], Gem::ConfigMap[:ruby_install_name],
                    Gem::ConfigMap[:ruby_version], "rubygems.rb")
  rescue Exception => e
    puts "Error loading gem paths on load path in gem_prelude"
    puts e
    puts e.backtrace.join("\n")
  end

end

