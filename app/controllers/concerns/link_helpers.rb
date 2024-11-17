module LinkHelpers
  extend ActiveSupport::Concern

  def generate_short_url
    loop do
      short_url_code = Link.generate_short_code
      short_url_new = "#{request.base_url}/#{short_url_code}"

      break short_url_new unless Link.exists?(short_url: short_url_new)
    end
  end

  def render_error(template:, message:, status:)
    @error = { message: }
    render template, status:
  end
end
