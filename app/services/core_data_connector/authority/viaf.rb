module CoreDataConnector
  module Authority
    BASE_URL = 'https://viaf.org'

    DEFAULT_LIMIT = 20

    class Viaf
      include Http

      def find(id, options = {})
        send_request("#{BASE_URL}/viaf/#{id}/viaf.json", method: :get)
      end

      def search(query, options = {})
        params = {
          query: query
        }

        send_request("#{BASE_URL}/viaf/AutoSuggest", method: :get, params: params)
      end
    end
  end
end