module CoreDataConnector
  module Authority
    BASE_URL = 'https://discover.libraryhub.jisc.ac.uk/search'

    DEFAULT_LIMIT = 20

    class Jisc
      include Http

      def find(id, options = {})
        params = {
          format: 'json',
          id: id
        }

        send_request(BASE_URL, method: :get, params: params)
      end

      def search(query, options = {})
        params = {
          format: 'json',
          keyword: query
        }

        send_request(BASE_URL, method: :get, params: params)
      end
    end
  end
end