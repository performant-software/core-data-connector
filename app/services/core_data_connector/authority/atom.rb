module CoreDataConnector
  module Authority
    class Atom
      include Http

      def find(id, options = {})
        headers = {
          'REST-API-Key': options[:api_key]
        }

        send_request("#{options[:url]}/api/informationobjects/#{id}", headers: headers) do |body|
          JSON.parse(body)
        end
      end

      def search(query, options = {})
        params = {
          sq0: query
        }

        headers = {
          'REST-API-Key': options[:api_key]
        }

        send_request("#{options[:url]}/api/informationobjects", headers: headers, params: params) do |body|
          JSON.parse(body)
        end
      end
    end
  end
end