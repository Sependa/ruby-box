#encoding: UTF-8

require 'ruby-box'
require 'webmock/rspec'

describe RubyBox::Item do

  before do
    @session = RubyBox::Session.new
    @client  = RubyBox::Client.new(@session)
  end

  describe '#factory' do

    it 'creates an object from a web_link hash' do
      web_link = RubyBox::Item.factory(@session, {
        'type' => 'web_link'
      })
      expect(web_link.type).to eq('web_link')
      expect(web_link.instance_of?(RubyBox::WebLink)).to eq(true)
    end

    it 'defaults to item object if unknown type' do
      banana = RubyBox::Item.factory(@session, {
        'type' => 'banana'
      })
      expect(banana.type).to eq('banana')
      expect(banana.instance_of?(RubyBox::Item)).to eq(true)
    end
  end
end
