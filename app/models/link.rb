class Link < ApplicationRecord
  SHORT_CODE_BYTE_SIZE = 4

  def self.generate_short_code
    SecureRandom.urlsafe_base64(SHORT_CODE_BYTE_SIZE)
  end
end
