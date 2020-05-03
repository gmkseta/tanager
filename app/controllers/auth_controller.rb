class AuthController < ApplicationController
  def status
    return render json: { errors: "jwt not available" }, status: :unauthorized if token.blank?
    user_provider = UserProvider.find_by!(token: token)
    if user_provider.declare_user.blank?
      render json: { status: "empty", jwt: user_provider.user.jwt }, status: :ok
    else
      render json: { status: user_provider.declare_user.status, jwt: user_provider.user.jwt }, status: :ok
    end
  rescue ActiveRecord::RecordNotFound => e
    businesses = get_businesses(token)
    user = CreateUser.call(businesses: businesses, token: token)
    render json: { status: "empty", jwt: user.jwt }, status: :ok
  end

  def destroy
    return render json: { errors: "jwt not available" }, status: :unauthorized if token.blank?
    user_provider = UserProvider.find_by!(token: token)
    user_provider.user.destroy
    render json: { status: "empty" }, status: :ok
  end

  private

  def auth_params
    params.permit(:provider, :declare_type)
  end

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
    uri = URI.parse(Rails.env.development? ? "https://staging-api.cashnote.kr/graphql" : "https://api.cashnote.kr/graphql")
    header = { "Authorization": "Bearer #{token}", "Content-Type": "application/json" }
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = { query: GetBusinesses }.to_json
    response = http.request(request)
    json_body = JSON.parse(response.body)
    Rails.logger.info("response json : #{json_body}")
    json_body["data"]["businesses"]["edges"].map { |obj| obj["node"] } rescue nil
  end

  def query(definition, variables = {}, context = {})
    response = Cashnote::Client.query(definition, variables: variables, context: context)
    if response.errors.any?
      raise QueryError.new(response.errors[:data].join(", "))
    else
      response.data
    end
  end
end
