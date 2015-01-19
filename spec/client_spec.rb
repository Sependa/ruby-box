#encoding: UTF-8

require 'spec_helper'
require 'helper/account'
require 'ruby-box'
require 'webmock/rspec'

describe RubyBox::Client do
  before do
    @session = RubyBox::Session.new
  end

  describe '#folder' do
    it "should return root folder as default behavior for paths such as ./" do
      client = RubyBox::Client.new(@session)
      expect(client).to receive(:root_folder).exactly(4).times

      client.folder()
      client.folder('.')
      client.folder('./')
      client.folder('/')
    end
  end

  describe '#split_path' do
    it "returns the appropriate path" do
      client = RubyBox::Client.new(@session)
      expect(client.split_path('foo/bar')).to eq(['foo', 'bar'])
    end

    it "leading / is ignored" do
      client = RubyBox::Client.new(@session)
      expect(client.split_path('/foo/bar')).to eq(['foo', 'bar'])
    end

    it "trailing / is ignored" do
      client = RubyBox::Client.new(@session)
      expect(client.split_path('foo/bar/')).to eq(['foo', 'bar'])
    end
  end

  describe '#create_folder' do
    it 'doesnt call folder.create_folder if the folder exists' do
      client = RubyBox::Client.new(@session)
      mock_root_folder = double( Object )
      test_folder = double( Object )
      expect(mock_root_folder).to receive(:folders).and_return([test_folder])
      expect(mock_root_folder).not_to receive(:create_subfolder)
      expect(client).to receive(:root_folder).and_return(mock_root_folder)
      result = client.create_folder( '/test0')
      expect(result).to eq(test_folder)
    end

    it 'calls folder.create_folder if the folder does not exist' do
      client = RubyBox::Client.new(@session)
      mock_root_folder = double( Object )
      test_folder = double( Object )
      expect(mock_root_folder).to receive(:folders).and_return([])
      expect(mock_root_folder).to receive(:create_subfolder).and_return(test_folder)
      expect(client).to receive(:root_folder).and_return(mock_root_folder)
      result = client.create_folder( '/test0')
      expect(result).to eq(test_folder)
    end
  end
end