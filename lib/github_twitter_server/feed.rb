require 'time'
require 'sax-machine'
require 'github_twitter_server/events'

module GithubTwitterServer
  class Feed
    attr_reader :response

    def initialize(response)
      @response = response
    end

    def entries
      atom.entries
    end

    def atom
      @atom ||= Atom.parse(response.body)
    end

    class AtomEntry
      STATUS = {:source => 'github', :source_href => 'http://github.com'}.freeze

      include SAXMachine
      element :id, :as => :guid
      element :updated
      element :title
      element :author,  :as => :author_name
      element :content, :as => :raw_content
      element :link, :value => :href, :with => {:type => "text/html", :rel => 'alternate'}

      def twitter_status
        STATUS.merge(:id => status_id, :text => status_text, :user => twitter_user)
      end

      def twitter_user
        {:screen_name => author}
      end

      def content
        extend_for_event_type
        content
      end

      def project
        extend_for_event_type
        project
      end

      def status_text
        project ? "@#{project} #{content}" : content
      end

      def author
        @author ||= begin
          author_name.strip!
          author_name
        end
      end

      def event_type
        @event_type ||= guid.scan(/\:(\w+)\/\d+$/)[0][0]
      end

      def status_id
        @status_id ||= guid.to_s.split('/').last
      end

      def updated_at
        @updated_at ||= Time.parse(updated)
      end

      def parsed_content
        @parsed_content ||= begin
          raw_content.gsub! /<(.|\n)+?>/, ''
          raw_content.gsub! /\s+/, ' '
          raw_content.strip!
          raw_content
        end
      end

      def extend_for_event_type
        extend Events.const_defined?(event_type) ?
          Events.const_get(event_type)           :
          Events::GenericEvent
      end
    end

    class Atom
      include SAXMachine
      elements :entry, :as => :entries, :class => AtomEntry
    end
  end
end