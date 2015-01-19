#encoding: UTF-8

require 'ruby-box'
require 'webmock/rspec'

describe '/users' do
  before do
    @session = RubyBox::Session.new
    @client  = RubyBox::Client.new(@session)
    @users_json = File.read 'spec/fixtures/users.json'
    @users = JSON.load(@users_json)
    stub_request(:get, /#{RubyBox::API_URL}\/users/).to_return(body: @users_json, :status => 200)
  end

  it 'should return a list of all users in the enterprise' do
    users  = @client.users
    expect(users.instance_of?(Array)).to eq(true)
  end

  it 'should return a list of all users in the enterprise as a user object' do
    users  = @client.users
    expect(users.first.instance_of?(RubyBox::User)).to eq(true)
  end
end