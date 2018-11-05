require "faraday_middleware"

module FreckleIO
  module Request
    class MultiplePages
      attr_reader :path
      attr_reader :params
      attr_reader :last_responses

      def get(path, params: {})
        @path ||= path
        @params ||= default_params.merge(params)

        retrieve_all_pages

        self
      end

      private

      def retrieve_all_pages
        merged_params =

        @last_responses ||= client.get_in_parallel(
          path,
          2,
          total_pages,
          params: params
        )

        @last_responses.unshift([@first_response])
        @last_responses.flatten!
      end

      def total_pages
        @total_pages ||= first_page.total_pages
      end

      def first_page
        @first_page ||= first_single_page.get(
          path,
          params: params
        )
        @first_response = @first_page.last_response

        @first_page
      end

      def first_single_page
        @first_single_page ||= FreckleIO::Request::SinglePage.new
      end

      def client
        @client ||= FreckleIO::Connection.new
      end

      def default_params
        {
          per_page: 10
        }
      end
    end
  end
end
