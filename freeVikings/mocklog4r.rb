# mocklog4r.rb
# igneus 10.9.2008

# Fake Log4r for those who can't or don't want to install Log4r;
# If Log4r isn't fount in the system, this file is loaded.

# mocklog4r normally ignores all logging except errors and fatal errors.
# If you need also the other log messages, uncomment content of
# more logging methods.

require 'singleton'

module Log4r
  class Logger

    include Singleton

    def Logger.[](logger_id)
      return Logger.instance
    end

    def log(t, s)
      STDERR.puts "#{t.upcase}: #{s}"
    end

    def debug(s)
      # log "debug", s
    end

    def info(s)
      # log "info", s
    end

    def warn(s)
      # log "warn", s
    end

    def error(s)
      log "error", s
    end

    def fatal(s)
      log "fatal", s
    end
  end
end
