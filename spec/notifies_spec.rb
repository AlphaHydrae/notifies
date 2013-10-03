require 'helper'

describe Notifies do
  let(:random_message){ %w(apple orange lemon strawberry banana blueberry).sample }
  let(:random_options){ { ('a'..'b').to_a.sample.to_sym => (0..100).to_a.sample } }

  before :each do
    Notifies.enabled = true
    Notifies::NOTIFIERS.clear
  end

  it "should be enabled" do
    expect(Notifies.enabled?).to be_true
  end

  it "should have no preferred notifiers" do
    expect(Notifies.preferred).to be_empty
  end

  describe ".enabled=" do

    it "should disable notifications" do
      subject.enabled = false
      expect(subject.enabled?).to be_false
    end

    it "should re-enable notifications" do
      subject.enabled = false
      subject.enabled = true
      expect(subject.enabled?).to be_true
    end
  end
  
  describe ".register" do

    it "should register a notifier" do
      notifier = double
      subject.register :foo, notifier
      expect(Notifies::NOTIFIERS).to eq(foo: notifier)
    end

    it "should register notifiers in order" do
      foo, bar, baz = double, double, double
      subject.register :foo, foo
      subject.register :bar, bar
      subject.register :baz, baz
      expect(Notifies::NOTIFIERS.values).to eq([ foo, bar, baz ])
    end
  end

  describe ".register_defaults" do

    before :each do
      subject.register_defaults
    end

    it "should register the notification center" do
      expect(subject.notifier(:notification_center)).to be(Notifies::NotificationCenter)
    end

    it "should register growl" do
      expect(subject.notifier(:growl)).to be(Notifies::Growl)
    end

    it "should register defaults in the correct order" do
      expect(subject.preferred).to eq([ :notification_center, :growl ])
    end
  end

  describe ".notify" do

    it "should return nil with no notifiers" do
      expect(subject.notify('foo')).to be_nil
    end

    it "should call a registered notifier" do
      foo = register :foo
      expect(foo).to receive(:notify).with(*random_notify_args)
      subject.notify *random_notify_args
    end

    it "should call the first available notifier" do
      foo, bar, baz = register(:foo, available?: false), register(:bar), register(:baz)
      expect(foo).not_to receive(:notify)
      expect(baz).not_to receive(:notify)
      expect(bar).to receive(:notify).with(*random_notify_args)
      subject.notify *random_notify_args
    end

    it "should call the first available notifier starting with the one specified by the :preferred option" do
      foo, bar, baz = register(:foo, available?: false), register(:bar), register(:baz)
      expect(foo).not_to receive(:notify)
      expect(bar).not_to receive(:notify)
      expect(baz).to receive(:notify).with(*random_notify_args)
      subject.notify *random_notify_args(preferred: :baz)
    end

    it "should call the first available notifier trying in the order specified by the :preferred option" do
      foo, bar, baz = register(:foo), register(:bar), register(:baz, available?: false)
      expect(foo).not_to receive(:notify)
      expect(baz).not_to receive(:notify)
      expect(bar).to receive(:notify).with(*random_notify_args)
      subject.notify *random_notify_args(preferred: [ :baz, :bar, :foo ])
    end

    it "should call the first available notifier trying in the order specified by calling :prefer=" do
      foo, bar, baz = register(:foo), register(:bar), register(:baz, available?: false)
      expect(foo).not_to receive(:notify)
      expect(baz).not_to receive(:notify)
      expect(bar).to receive(:notify).with(*random_notify_args)
      subject.prefer :baz, :bar, :foo
      subject.notify *random_notify_args
    end

    it "should raise an error if no notifier is registered under a key in the :preferred option" do
      foo = register :foo
      expect(foo).not_to receive(:notify)
      expect{ subject.notify *random_notify_args(preferred: :bar) }.to raise_error(Notifies::UnknownNotifierError, "Unknown notifier(s) :bar")
      expect{ subject.notify *random_notify_args(preferred: [ :foo, :baz ]) }.to raise_error(Notifies::UnknownNotifierError, "Unknown notifier(s) :baz")
      expect{ subject.notify *random_notify_args(preferred: [ :bar, :baz ]) }.to raise_error(Notifies::UnknownNotifierError, "Unknown notifier(s) :bar, :baz")
    end

    it "should return false if the notifier fails" do
      foo = register :foo, notify: false
      expect(foo).to receive(:notify).with('strawberry', c: 1)
      expect(subject.notify('strawberry', c: 1)).to be_false
    end

    it "should return false if notifications are disabled" do
      foo = register :foo
      Notifies.enabled = false
      expect(foo).not_to receive(:notify)
      expect(subject.notify('blueberry', d: 25)).to be_false
    end

    it "should return false if manually disabled" do
      foo = register :foo
      expect(foo).not_to receive(:notify)
      [ nil, false ].each do |falsy|
        expect(subject.notify('banana', e: 42, enabled: falsy)).to be_false
      end
    end
  end

  describe ".notifier" do

    it "should return nil with no notifiers" do
      expect(subject.notifier).to be_nil
    end

    it "should return a registered notifier" do
      foo = register :foo
      expect(subject.notifier).to be(foo)
    end

    it "should return the first available notifier" do
      foo, bar, baz = register(:foo, available?: false), register(:bar), register(:baz)
      expect(subject.notifier).to be(bar)
    end

    it "should return the first available notifier starting with the one specified by the :preferred option" do
      foo, bar, baz = register(:foo, available?: false), register(:bar), register(:baz)
      expect(subject.notifier(preferred: :baz)).to be(baz)
    end

    it "should return the first available notifier trying in the order specified by the :preferred option" do
      foo, bar, baz = register(:foo), register(:bar), register(:baz, available?: false)
      expect(subject.notifier(preferred: [ :baz, :bar, :foo  ])).to be(bar)
    end

    it "should return the first available notifier trying in the order specified by calling :prefer=" do
      foo, bar, baz = register(:foo), register(:bar), register(:baz, available?: false)
      subject.prefer :baz, :bar, :foo
      expect(subject.notifier).to be(bar)
    end

    it "should raise an error if no notifier is registered under a key in the :preferred option" do
      foo = register :foo
      expect{ subject.notifier preferred: :bar }.to raise_error(Notifies::UnknownNotifierError, "Unknown notifier(s) :bar")
      expect{ subject.notifier preferred: [ :foo, :baz ] }.to raise_error(Notifies::UnknownNotifierError, "Unknown notifier(s) :baz")
      expect{ subject.notifier preferred: [ :bar, :baz ] }.to raise_error(Notifies::UnknownNotifierError, "Unknown notifier(s) :bar, :baz")
    end

    it "should return the notifier registered under the specified key" do
      foo, bar, baz = register(:foo, available?: false), register(:bar), register(:baz)
      expect(subject.notifier(:foo)).to be(foo)
      expect(subject.notifier(:bar)).to be(bar)
      expect(subject.notifier(:baz)).to be(baz)
    end

    it "should return the notifier registered under the specified key if available with the :available option" do
      foo, bar, baz = register(:foo, available?: false), register(:bar), register(:baz)
      expect(subject.notifier(:foo, available: true)).to be_nil
      expect(subject.notifier(:bar, available: true)).to be(bar)
      expect(subject.notifier(:baz, available: true)).to be(baz)
    end

    it "should raise an error if no notifier is registered under the specified key" do
      foo = register :foo
      expect{ subject.notifier(:bar) }.to raise_error(Notifies::UnknownNotifierError, "Unknown notifier(s) :bar")
    end
  end

  describe ".preferred" do
    
    it "should return notifier keys in the order they were registered" do
      foo, bar, baz = register(:foo), register(:bar), register(:baz)
      expect(subject.preferred).to eq([ :foo, :bar, :baz ])
    end
  end

  describe ".prefer" do

    it "should change the preferred order" do
      foo, bar, baz = register(:foo), register(:bar), register(:baz)
      subject.prefer :bar, :foo, :baz
      expect(subject.preferred).to eq([ :bar, :foo, :baz ])
    end

    it "should put the only preferred item first" do
      foo, bar, baz = register(:foo), register(:bar), register(:baz)
      subject.prefer :baz
      expect(subject.preferred).to eq([ :baz, :foo, :bar ])
    end

    it "should put the specified preferred items first" do
      foo, bar, baz = register(:foo), register(:bar), register(:baz)
      subject.prefer :baz, :foo
      expect(subject.preferred).to eq([ :baz, :foo, :bar ])
    end

    it "should ignore duplicate items" do
      foo, bar, baz = register(:foo), register(:bar), register(:baz)
      subject.prefer :bar, :foo, :foo, :baz, :bar, :bar, :baz
      expect(subject.preferred).to eq([ :bar, :foo, :baz ])
    end
  end

  describe "aliases" do

    before :each do
      Notifies.stub notify: true
    end

    %w(ok info warning error).each do |type|
      it "should call notify with type :#{type} when notify_#{type} is called" do
        expect(Notifies).to receive(:notify).with(*random_notify_args(type: type.to_sym))
        Notifies.send "notify_#{type}", *random_notify_args
      end
    end
  end

  def random_notify_args options = {}
    [ random_message.dup, random_options.dup.merge(options) ]
  end

  def register key, options = {}
    double({ available?: true, notify: true }.merge(options)).tap do |notifier|
      Notifies.register key, notifier
    end
  end
end
