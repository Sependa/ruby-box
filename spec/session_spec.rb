#encoding: UTF-8

require 'spec_helper'
require 'ruby-box'

describe RubyBox::Session do
  before do
    @auth_code = double("OAuth2::Strategy::AuthCode")
    @client = double("OAuth2::Client")

    allow(@client).to receive(:auth_code) { @auth_code }
    allow(OAuth2::Client).to receive(:new) { @client }

    @session = RubyBox::Session.new({
      client_id: "client id",
      client_secret: "client secret"
    })
  end

  let(:redirect_uri) { "redirect_uri" }
  let(:state) { "state" }

  describe '#authorize_url' do
    it "should accept redirect_uri" do
      expect(@auth_code).to receive(:authorize_url).with({ redirect_uri: redirect_uri})
      @session.authorize_url(redirect_uri)
    end

    it "should accept redirect_uri and state" do
      expect(@auth_code).to receive(:authorize_url).with({ redirect_uri: redirect_uri, state: state})
      @session.authorize_url(redirect_uri, state)
    end
  end
end
