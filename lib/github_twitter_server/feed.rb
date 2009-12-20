require 'time'
require 'sax-machine'

module GithubTwitterServer
  class Feed
    attr_reader :connection, :url

    def initialize(conn, url)
      @connection = conn
      @url = url
    end

    def atom_response
      @connection.get(@url)
    end

    def entries
      atom.entries
    end

    def atom
      @atom ||= Atom.parse(atom_response.body)
    end

    class AtomEntry
      include SAXMachine
      element :id, :as => :guid
      element :updated
      element :author,  :as => :author_name
      element :content, :as => :raw_content
      element :link, :value => :href, :with => {:type => "text/html", :rel => 'alternate'}

      def parsed_content
        @parsed_content ||= begin
          raw_content.gsub! /<(.|\n)+?>/, ''
          raw_content.gsub! /\s+/, ' '
          raw_content.strip!
          raw_content
        end
      end

      def content
        @content ||= case event_type
          when 'CommitCommentEvent'
            parse_comment_event(parsed_content)
          when 'PushEvent'
            parse_push_event(parsed_content)
          else
            parsed_content
        end
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

      # Comment in a18f575: this mess is gonna get raw, like sushi =>
      # @c_a18f575 this mess is gonna get raw, like sushi
      def parse_comment_event(text)
        # pull out commit hash and comment
        if text =~ /(\w+)\: (.+)$/
          "@c_#{$1} #{$2}"
        else
          text
        end
      end

      # put each commit on a line
      # @link users
      # @link commits
      def parse_push_event(text)
        text = text.dup
        # parse out "HEAD IS (sha)"
        text.gsub! /^HEAD is \w+ /, ''
        # [['technoweenie', 'sha1'], ['technoweenie', 'sha2']]
        commits = text.scan(/(\w+) committed (\w+):/)
        msgs    = text.split(/\w+ committed \w+: /)
        msgs.shift
        s = []
        commits.each_with_index do |(user, sha), idx|
          s << "#{"@#{user} " if user != author}#{sha} #{msgs[idx]}".strip
        end
        s = s * "\n"
        case commits.size
          when 1 then s
          when 0 then ''
          else "#{commits.size} commits: #{s}"
        end
      end
    end

    class Atom
      include SAXMachine
      elements :entry, :as => :entries, :class => AtomEntry
    end
  end
end