module CoreDataConnector
  module Authority
    class Geonames < Base
      include Http::Requestable

      BASE_URL = 'http://api.geonames.org'

      def find(id, _options = {})
        params = {
          geonameId: id,
          username: ENV['GEONAMES_USER']
        }
        send_request("#{BASE_URL}/getJSON", method: :get, params:) do |body|
          JSON.parse(body)
        end
      end

      def search(query, _options = {})
        params = {
          q: query,
          username: ENV['GEONAMES_USER']
        }
        send_request("#{BASE_URL}/searchJSON?", method: :get, params:) do |body|
          JSON.parse(body)
        end
      end
    end
  end
end
