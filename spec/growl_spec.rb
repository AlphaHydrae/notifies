require 'helper'

describe Notifies::Growl do
  subject{ Notifies::Growl }

  before :each do
    Growl.stub notify_ok: true, notify_info: true, notify_warning: true, notify_error: true
  end

  it "should be available if growl is installed" do
    Growl.stub installed?: '2.1'
    expect(subject.available?).to be_true
    Growl.stub installed?: false
    expect(subject.available?).to be_false
  end

  shared_examples_for "a growl method" do |type,expected_method|
    let(:options){ Hash.new.tap{ |h| h[:type] = type if type } }

    it "should call the correct method" do
      expect(Growl).to receive(expected_method).with('msg', {})
      subject.notify 'msg', options
    end

    it "should pass the :title option as :name" do
      expect(Growl).to receive(expected_method).with('msg', name: 'foo')
      subject.notify 'msg', options.merge(title: 'foo')
    end

    it "should pass the :subtitle option as :title" do
      expect(Growl).to receive(expected_method).with('msg', title: 'bar')
      subject.notify 'msg', options.merge(subtitle: 'bar')
    end

    it "should pass the :icon option" do
      expect(Growl).to receive(expected_method).with('msg', icon: 'img.jpg')
      subject.notify 'msg', options.merge(icon: 'img.jpg')
    end

    it "should correctly handle all options" do
      expect(Growl).to receive(expected_method).with('msg', name: 'foo', title: 'bar', icon: 'img.jpg')
      subject.notify 'msg', options.merge(title: 'foo', subtitle: 'bar', icon: 'img.jpg')
    end
  end

  it_should_behave_like "a growl method", :ok, :notify_ok
  it_should_behave_like "a growl method", :info, :notify_info
  it_should_behave_like "a growl method", :warning, :notify_warning
  it_should_behave_like "a growl method", :error, :notify_error
  it_should_behave_like "a growl method", nil, :notify_info
  it_should_behave_like "a growl method", :unknown, :notify_info
end
