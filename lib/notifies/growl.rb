# encoding: UTF-8
require 'growl'

module Notifies

  class Growl

    def self.available?
      !!::Growl.installed?
    end

    def self.notify msg, options = {}
      method = METHODS[options.delete(:type)] || :notify_info
      ::Growl.send method, msg, growl_options(options)
    end

    private

    METHODS = {
      ok: :notify_ok,
      info: :notify_info,
      warning: :notify_warning,
      error: :notify_error
    }

    def self.growl_options options = {}
      Hash.new.tap do |h|
        h[:name] = options[:title] if options[:title]
        h[:title] = options[:subtitle] if options[:subtitle]
        h[:icon] = options[:icon] if options[:icon]
      end
    end
  end
end
