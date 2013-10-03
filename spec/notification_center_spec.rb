require 'helper'

describe Notifies::NotificationCenter do
  subject{ Notifies::NotificationCenter }

  before :each do
    TerminalNotifier::Guard.stub success: true, notify: true, pending: true, failed: true
  end

  it "should be available if the guard terminal notifier is available" do
    TerminalNotifier::Guard.stub available?: true
    expect(subject.available?).to be_true
    TerminalNotifier::Guard.stub available?: false
    expect(subject.available?).to be_false
  end

  shared_examples_for "a notification center method" do |type,expected_method|
    let(:options){ Hash.new.tap{ |h| h[:type] = type if type } }

    it "should call the correct method" do
      expect(TerminalNotifier::Guard).to receive(expected_method).with('msg', {})
      subject.notify 'msg', options
    end

    it "should pass the :title option" do
      expect(TerminalNotifier::Guard).to receive(expected_method).with('msg', title: 'foo')
      subject.notify 'msg', options.merge(title: 'foo')
    end

    it "should pass the :subtitle option" do
      expect(TerminalNotifier::Guard).to receive(expected_method).with('msg', subtitle: 'bar')
      subject.notify 'msg', options.merge(subtitle: 'bar')
    end

    it "should not pass the :icon option" do
      expect(TerminalNotifier::Guard).to receive(expected_method).with('msg', {})
      subject.notify 'msg', options.merge(icon: 'img.jpg')
    end

    it "should correctly handle all options" do
      expect(TerminalNotifier::Guard).to receive(expected_method).with('msg', title: 'foo', subtitle: 'bar')
      subject.notify 'msg', options.merge(title: 'foo', subtitle: 'bar', icon: 'img.jpg')
    end
  end

  it_should_behave_like "a notification center method", :ok, :success
  it_should_behave_like "a notification center method", :info, :notify
  it_should_behave_like "a notification center method", :warning, :pending
  it_should_behave_like "a notification center method", :error, :failed
  it_should_behave_like "a notification center method", nil, :notify
  it_should_behave_like "a notification center method", :unknown, :notify
end
