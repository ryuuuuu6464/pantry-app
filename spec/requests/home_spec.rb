require 'rails_helper'

RSpec.describe 'HomeController', type: :request do
  describe 'GET #index' do
    it '未ログインならログイン画面へリダイレクトする' do
      get '/home/index'
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
