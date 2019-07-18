require 'rails_helper'

RSpec.describe WelcomeController, type: :controller do
  context 'SIGN IN RECORD create_visitor' do  # (almost) plain English
    before do
      @json =  {
          person_id: 'bilel.kedidi@gmail.com',
          person_image_url: 'YH0zWTnJmijBbojT4GX0JzHdX/ACec3Gf61ssTUStcrkp7iv8AB3WWGF1',
          update_contact: 'true',
          person_name: 'bilel',
          company: ' B-Solution',
          phone: '555555',
          email: 'bilel.kedidi@gmail.com',
          reason: '1',
          person_visiting: '1',
          citizen: 'true',
          classified: 'false',
          person_signature_url: 'YH0zWTnJmijBbojT4GX0JzHdX/ACec3Gf61ssTUStcrkp7iv8AB3WWGF1'
      }
    end
    it 'I try to sign in without avatar' do
      @json[:person_image_url] = ''
      request.env['CONTENT_TYPE'] = 'application/json'
      post :create_visitor, { :format => :json, params: @json }
      expect(JSON.parse(response.body)["success"]).to eq(false)
      expect(JSON.parse(response.body)["errors"].count).to eq(1)
      expect(JSON.parse(response.body)["errors"].first).to eq("Avatar can't be blank")
    end

    it 'I try to Sign in without signature' do
      @json[:person_signature_url] = ''
      request.env['CONTENT_TYPE'] = 'application/json'
      post :create_visitor, { :format => :json, params: @json }
      expect(JSON.parse(response.body)["success"]).to eq(true)
      expect(JSON.parse(response.body)['attributes']["person_signature"]).to eq('')
    end
    it 'I try to Sign in with signature' do
      # @json[:person_signature_url] = ''
      request.env['CONTENT_TYPE'] = 'application/json'
      post :create_visitor, { :format => :json, params: @json }
      expect(JSON.parse(response.body)["success"]).to eq(true)
      expect(JSON.parse(response.body)['attributes']["person_signature"]).to eq(@json[:person_signature_url])
    end

    # it 'I try to sign in when i already signed in and did not sign out' do
    #   request.env['CONTENT_TYPE'] = 'application/json'
    #   binding.pry
    #   post :create_visitor, { :format => :json, params: @json }
    #
    #   # sleep(1)
    #   binding.pry
    #   request.env['CONTENT_TYPE'] = 'application/json'
    #   post :create_visitor, { :format => :json, params: @json }
    #   expect(JSON.parse(response.body)["success"]).to eq(false)
    #   binding.pry
    # end

    it 'I try to sign in with missing info' do
      @json[:person_name] = ''
      request.env['CONTENT_TYPE'] = 'application/json'
      post :create_visitor, { :format => :json, params: @json }
      expect(JSON.parse(response.body)["success"]).to eq(false)
      # expect(JSON.parse(response.body)['attributes']["person_signature"]).to eq(@json[:person_signature_url])
    end

  end
end
