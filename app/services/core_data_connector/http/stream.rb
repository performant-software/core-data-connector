require 'typhoeus'

module CoreDataConnector
  module Http
    class Stream

      attr_reader :url

      def initialize(url)
        @url = url
      end

      def download
        file = Tempfile.create(binmode: true)

        request = Typhoeus::Request.new(url)
        request.on_body { |chunk| file.write chunk }
        request.on_complete { file.rewind }
        request.run

        file
      end

    end
  end
end