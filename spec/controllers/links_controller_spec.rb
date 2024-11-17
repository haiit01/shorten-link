require 'rails_helper'

RSpec.describe LinksController, type: :controller do
  let(:valid_url) { 'https://codesubmit.io/library/react' }
  let(:invalid_url) { 'htp://not-valid-url' }
  let(:link) { create(:link, original_url: valid_url, short_url: "#{request.base_url}/shortcode") }

  describe "POST #encode" do
    context "when the URL is valid" do
      it "creates a new short link and returns the short URL" do
        post "encode", params: { original_link: valid_url }, as: :json
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['short_url']).to be_present
      end
    end

    context "when the URL is invalid" do
      it "returns a bad request error" do
        post :encode, params: { original_link: invalid_url }, as: :json

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to eq("URL is invalid")
      end
    end

    context "when the URL is not provided" do
      it "returns a bad request error" do
        post :encode, params: {}, as: :json

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to eq("URL is invalid")
      end
    end

    context "when the URL has the same domain as the app" do
      it "returns a bad request error" do
        post :encode, params: { original_link: request.base_url }, as: :json

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to eq("URL is invalid")
      end
    end

    context "when the short URL already exists" do
      before do
        allow(Link).to receive(:exists?).and_return(true, false)
      end

      it "generates a new unique short URL" do
        post :encode, params: { original_link: valid_url }, as: :json

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['short_url']).to be_present
      end
    end

    context "when unable to create a new Link record" do
      it "returns an internal server error" do
        allow(Link).to receive(:create).and_return(double(persisted?: false))

        post :encode, params: { original_link: valid_url }, as: :json

        expect(response).to have_http_status(:internal_server_error)
        expect(JSON.parse(response.body)['error']).to eq("Unable to create short link")
      end
    end
  end

  describe "GET #decode" do
    context "when the short URL exists" do
      it "returns the original URL" do
        get :decode, params: { short_link: link.short_url }, as: :json

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['original_url']).to eq(link.original_url)
      end
    end

    context "when the short URL does not exist" do
      it "returns a not found error" do
        get :decode, params: { short_link: 'nonexistent' }, as: :json

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq("Not Found")
      end
    end

    context "when the short URL is not provided" do
      it "returns a not found error" do
        get :decode, params: {}, as: :json

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq("Not Found")
      end
    end
  end

  describe "GET #redirect_to_original" do
    context "when the short link exists" do
      it "redirects to the original URL and allows redirection to an external host" do
        link
        get :redirect_to_original, params: { short_code: "shortcode" }
        expect(response).to redirect_to(valid_url)
        expect(response.status).to eq(302)
      end
    end

    context "when the short link does not exist" do
      it "returns a 404 status code and renders the 'Not found' message" do
        get :redirect_to_original, params: { short_code: "nonexistent" }

        expect(response).to have_http_status(:not_found)
        expect(response.body).to eq("Not found")
      end
    end
  end
end
