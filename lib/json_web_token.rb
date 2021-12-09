class JsonWebToken
  ALGORITHM = "HS256"

  class << self
    def token_secret
      ENV["JWT_AUTH_SECRET"] || Rails.application.secrets.secret_key_base || 'sistema-plantillas'
    end

    def encode(payload, exp = 1.years.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, token_secret, ALGORITHM)

    end

    def decode(token)
      body = JWT.decode(token, token_secret, false, {algorithm: ALGORITHM})[0]
      return HashWithIndifferentAccess.new body
    rescue JWT::ExpiredSignature, JWT::VerificationError => e
      raise ExceptionHandler::ExpiredSignature, e.message
    rescue JWT::DecodeError, JWT::VerificationError => e
      raise ExceptionHandler::DecodeError, e.message
    end
  end
end
