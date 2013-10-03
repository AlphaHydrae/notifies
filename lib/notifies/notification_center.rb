# encoding: UTF-8
require 'terminal-notifier-guard'

module Notifies

  class NotificationCenter

    def self.available?
      !!TerminalNotifier::Guard.available?
    end

    def self.notify msg, options = {}
      method = METHODS[options.delete(:type)] || :notify
      TerminalNotifier::Guard.send method, msg, terminal_notifier_options(options)
    end

    private

    METHODS = {
      ok: :success,
      info: :notify,
      warning: :pending,
      error: :failed
    }

    def self.terminal_notifier_options options = {}
      Hash.new.tap do |h|
        h[:title] = options[:title] if options[:title]
        h[:subtitle] = options[:subtitle] if options[:subtitle]
      end
    end
  end
end
