module GithubTwitterServer
  # these modules extend Feed instances for custom parsing
  module Events
    module GenericEvent
      def project
      end

      def content
        @content ||= parsed_content
      end
    end

    module IssuesEvent
      include GenericEvent

      def project
        @project ||= \
          if title =~ /\w+ opened issue \d+ on (.*)$/
            $1
          else
            nil
          end
      end
    end

    module CommitCommentEvent
      def project
        if title =~ /\w+ commented on (.*)$/
          $1
        else
          nil
        end
      end

      # Comment in a18f575: this mess is gonna get raw, like sushi =>
      # @c_a18f575 this mess is gonna get raw, like sushi
      def content
        @content ||= begin
          # pull out commit hash and comment
          if parsed_content =~ /(\w+)\: (.+)$/
            "@c_#{$1} #{$2}"
          else
            parsed_content
          end
        end
      end
    end

    module PushEvent
      def project
        @project ||= \
          if title =~ /\w+ pushed to \w+ at (.*)$/
            $1
          else
            nil
          end
      end

      # put each commit on a line
      # @link users
      # @link commits
      def content
        @content ||= begin
          parsed_content.dup.tap do |text|
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
            text.replace \
              case commits.size
                when 1 then s
                when 0 then ''
                else "#{commits.size} commits: #{s}"
              end
          end
        end
      end
    end
  end
end