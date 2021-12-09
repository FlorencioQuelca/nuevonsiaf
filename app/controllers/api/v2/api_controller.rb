module Api
  module V2
    class ApiController < ApplicationController
      include ExceptionHandler
      require 'json_web_token'
      skip_before_action :authenticate_user!
      skip_before_action :verify_authenticity_token

      before_action :authenticate_request!

      protected

      def authenticate_request!
        if !http_token
          raise AuthenticationError, "No autenticado: Requiere Authorization-Token"
        end

        if ApiToken.find_by(token: http_token, status: '1').nil?
          raise AuthenticationError, "Token inválido"
        end

        unless user_id_in_token?
          raise AuthenticationError, "Not autenticado: Formato de solicitud incorrecto"
        end
        # @current_user = User.find(auth_token[:user_id])
      rescue JWT::VerificationError
        raise InvalidToken, "Not autenticado: Token invalido"
      rescue JWT::DecodeError
        raise DecodeError, "Not autenticado: DecodeError, Bad tok format"
      end

      private

      def http_token
        return request.headers["Authorization"].split(" ").last if request.headers["Authorization"].present?
        nil
      end

      def auth_token
        JsonWebToken.decode(http_token)
      end

      def user_id_in_token?
        http_token && auth_token && auth_token[:user_id].to_i
      end
    end
  end
end
