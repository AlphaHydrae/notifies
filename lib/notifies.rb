# encoding: UTF-8

module Notifies
  VERSION = '0.1.0'
  NOTIFIERS = {}
  @@enabled = true

  class Error < StandardError; end
  class UnknownNotifierError < Error
    
    def initialize msg
      super "Unknown notifier(s) #{msg}"
    end
  end

  def self.notify msg, options = {}
    return false if !@@enabled or (options.key?(:enabled) and !options[:enabled])
    n = notifier options
    n ? n.notify(msg, options) : nil
  end

  class << self
    [ :ok, :info, :warning, :error ].each do |type|
      define_method "notify_#{type}" do |*args|
        options = args.last.kind_of?(Hash) ? args.last : {}.tap{ |h| args << h }
        options[:type] = type
        notify *args
      end
    end
  end

  def self.notifier *args
    options = args.last.kind_of?(Hash) ? args.pop : {}

    if key = args.shift
      raise UnknownNotifierError.new(key.inspect) unless n = NOTIFIERS[key]
      return !options[:available] || n && n.available? ? n : nil
    end

    ordered_notifiers(options).each_pair do |key,notifier|
      return notifier if notifier.available?
    end

    nil
  end

  def self.preferred
    NOTIFIERS.keys
  end

  def self.prefer *keys
    NOTIFIERS.replace(ordered_notifiers(preferred: keys.flatten)).keys
  end

  def self.enabled= enabled
    @@enabled = !!enabled
  end

  def self.enabled?
    @@enabled
  end

  def self.register key, notifier
    # TODO: test key override
    NOTIFIERS[key] = notifier
  end

  def self.register_defaults
    register :notification_center, Notifies::NotificationCenter
    register :growl, Notifies::Growl
  end

  private

  def self.ordered_notifiers options = {}
    return NOTIFIERS unless options[:preferred]

    keys = [ options.delete(:preferred) ].flatten.uniq
    unknown_keys = keys.reject{ |k| NOTIFIERS[k] }
    raise UnknownNotifierError.new(unknown_keys.collect{ |k| k.inspect }.join(', ')) unless unknown_keys.empty?

    notifiers = NOTIFIERS.dup

    Hash.new.tap do |ordered|
      keys.each{ |k| ordered[k] = notifiers.delete k }
      notifiers.each_pair{ |k,v| ordered[k] = v }
    end
  end
end

Dir[File.join File.dirname(__FILE__), File.basename(__FILE__, '.*'), '*.rb'].each{ |lib| require lib }

Notifies.register_defaults
