class CashnotesController < ApplicationController
  skip_before_action :verify_authenticity_token

  LoginQuery = Cashnote::Client.parse <<-'GRAPHQL'
    mutation($login: ID!, $password: String!) {
      login(input: { login: $login, password: $password }) {
        jwt
        errors {
          field
          messages
        }
      }
    }
  GRAPHQL

  def login
    response = query LoginQuery, login: params[:login], password: params[:password]
    jwt_token = response.login.jwt
    if jwt_token.present?
      businesses = get_businesses(jwt_token)["data"]["businesses"]["edges"].map { |obj| obj["node"] } rescue nil
      user = User.find_by(login: params[:login])
      user ||=  User.create!(login: params[:login], name: businesses.first["name"], password: businesses.first["registrationNumber"])
      session[:user_id] = user.id
      data = { message: "success" }
      data[:redirect_to] = "/users/#{user.id}/edit" if user.created_at >= 1.minutes.ago
      render json: data, status: :ok
    else
      render json: { message: "로그인을 실패했습니다. 아이디 패스워드를 확인해주세요.\n캐시노트 회원이 아니라면 회원가입 이후 사용이 가능합니다." }, status: :bad_request
    end
  end

  LoginWithKakaoQuery = Cashnote::Client.parse <<-'GRAPHQL'
    mutation($accessToken: String!, $anonymousId: String, $inviterCode: String, $discountCode: String) {
      loginWithKakao(
        input: {
          accessToken: $accessToken
          anonymousId: $anonymousId
          inviterCode: $inviterCode
          discountCode: $discountCode
        }
      ) {
        jwt
        errors {
          field
          messages
        }
      }
    }
  GRAPHQL

  def login_with_kakao
    response = query LoginWithKakaoQuery, accessToken: params[:access_token]
    jwt_token = response.login.jwt
    if jwt_token.present?
      businesses = get_businesses(jwt_token)["data"]["businesses"]["edges"].map { |obj| obj["node"] } rescue nil
      user = User.find_by(login: businesses.first["registrationNumber"], name: businesses.first["registrationNumber"], password: businesses.first["registrationNumber"])
      user ||=  User.create!(login: params[:login], name: businesses.first["name"], password: businesses.first["registrationNumber"])
      
      render json: { message: "success" }, status: :ok
    else
      render json: { message: "로그인을 실패했습니다. 아이디 패스워드를 확인해주세요.\n캐시노트 회원이 아니라면 회원가입 이후 사용이 가능합니다." }, status: :bad_request
    end
  end

  private

  GetBusinesses = <<~QUERY
    query getBusinesses {
      businesses {
        edges {
          node {
            id
            name
            registrationNumber
          }
        }
      }
    }
  QUERY

  def get_businesses(token)
    uri = URI.parse("https://api.cashnote.kr/graphql")
    header = { "Authorization": "Bearer #{token}", "Content-Type": "application/json"}    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = { query: GetBusinesses }.to_json
    response = http.request(request)
    JSON.parse(response.body)
  end

end
