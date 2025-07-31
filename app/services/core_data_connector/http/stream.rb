require 'typhoeus'

module CoreDataConnector
  module Http
    class Stream

      attr_reader :url, :options

      def initialize(url, options = {})
        @url = url
        @options = options
      end

      def download
        file = Tempfile.create(binmode: true)

        request = Typhoeus::Request.new(url, options)
        request.on_body { |chunk| file.write chunk }
        request.on_complete { file.rewind }
        request.run

        file
      end

    end
  end
end