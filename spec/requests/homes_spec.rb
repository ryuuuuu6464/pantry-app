require 'rails_helper'

RSpec.describe 'HomesController', type: :request do
  describe 'GET #index' do
    it 'トップページにアクセスするとHTTPステータス200が返ること' do
      get root_path
      expect(response).to have_http_status(200)
    end
  end
end
