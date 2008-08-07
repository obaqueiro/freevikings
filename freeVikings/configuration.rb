# configuration.rb
# igneus 7.8.2008

# class Configuration and loader classes

module FreeVikings
  class Configuration < Hash
    # Special constructor which takes several Configuration instances
    # and returns one new, which is made applying one given instance after
    # another. The last has the highest authority.
    # Example: 
    #   FreeVikings::OPTIONS = Configuration.build_from(system_cfg, user_cfg, commandline_cfg)
    # In our example variables system_cfg, user_cfg, commandline_cfg contain
    # Configuration instances filled with the data of system configuration 
    # file, another configfile from the user's HOME directory and options
    # given on the command line.
    # The line of code above does exactly what we want - applies first the 
    # system configuration (what regular user would want), 
    # than the user's (what the current user usually wants) and last what was
    # given on the commandline (what the user wants now, extraordinarily).
    def Configuration.build_from(*configurations)
      newconfig = Configuration.new
      configurations.each {|c| newconfig.apply c}
      return newconfig
    end

    # Accepts all non-nil values of configuration.
    def apply(configuration)

    end
  end # class Configuration
end # module FreeVikings
