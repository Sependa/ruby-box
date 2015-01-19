#encoding: UTF-8

require 'ruby-box'
require 'webmock/rspec'

describe RubyBox::EventResponse do
  before do
    @session = RubyBox::Session.new
    @client  = RubyBox::Client.new(@session)
    @events_json  = File.read 'spec/fixtures/events.json'
    @events = JSON.load @events_json
    stub_request(:get, /#{RubyBox::API_URL}\/events.*/).to_return(body: @events_json, :status => 200)
  end

  it 'returns an EventResponse with a chunk_size and next_stream_position' do
    eresp = @client.event_response
    expect(eresp.instance_of?(RubyBox::EventResponse)).to eq(true)
    expect(eresp.events.instance_of?(Array)).to eq(true)
    expect(eresp.chunk_size).to eq(@events['chunk_size'])
    expect(eresp.events.length).to eq(@events['chunk_size'])
    expect(eresp.next_stream_position).to eq(@events['next_stream_position'])
  end

  it '#fmt_events_args should return a properly formatted URL' do
    expect(@client.send(:fmt_events_args, 0, :all, 100)).to eql("stream_position=0&stream_type=all&limit=100")
    expect(@client.send(:fmt_events_args, 'now', :changes, 55)).to eql("stream_position=now&stream_type=changes&limit=55")
  end

  describe '#event_response' do
    before do
      @response = @client.event_response
      @event = @response.events.first
    end

    it 'should return Event objects in the event response' do
      expect(@event.instance_of?(RubyBox::Event)).to eq(true)
    end

    it 'should return an #event_id' do
      expect(@event.event_id).to eq(@events['entries'][0]['event_id'])
    end

    it 'should return a User for #created_by' do
      expect(@event.created_by.instance_of?(RubyBox::User)).to eq(true)
    end

    it 'should return an #event_type' do
      expect(@event.event_type).to eq(@events['entries'][0]['event_type'])
    end

    it 'should return a #session_id' do
      expect(@event.session_id).to eq(@events['entries'][0]['session_id'])
    end

    it 'should return an instantiated #source' do
      expect(@event.source.instance_of?(RubyBox::Folder)).to eq(true)
    end
  end
end