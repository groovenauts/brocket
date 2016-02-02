require "brocket"

require 'logger_pipe/runner'

module BRocket
  class Git < Configurable

    desc "guard_clean", "Raise error if some difference exists."
    def guard_clean
      (clean? && committed?) ?
        success("[git guard_clean] OK") :
        error("There are files that need to be committed first. Run `git status`")
    end

    desc "push", "push commit and tag it"
    def push
      info("[git push] starting")
      tag_version { git_push } unless already_tagged?
      success("[git push] OK")
    end

    no_commands do

      # This method is called from BRocket::VersionFile#bump_on
      def add_and_commit(filepath, msg)
        sh("git add #{filepath} && git commit -m \"#{msg}\"")
      end

      def clean?
        sh("git diff --exit-code")
        return true
      rescue LoggerPipe::Failure
        return false
      end

      def committed?
        sh("git diff-index --quiet --cached HEAD")
        return true
      rescue LoggerPipe::Failure
        return false
      end

      def tag_version
        sh "git tag -a -m \"Version #{version_tag}\" #{version_tag}"
        $stdout.puts "Tagged #{version_tag}."
        yield if block_given?
      rescue
        $stderr.puts "Untagging #{version_tag} due to error."
        sh "git tag -d #{version_tag}"
        raise
      end

      def git_push
        perform_git_push
        perform_git_push '--tags'
        $stdout.puts "Pushed git commits and tags."
      end

      def perform_git_push(options = nil)
        sh(['git push', options].compact.join(' ' ))
      end

      def already_tagged?
        if sh('git tag').split(/\n/).include?(version_tag)
          $stderr.puts "Tag #{version_tag} has already been created."
          true
        end
      end

      def version_tag
        prefix = sub(Docker).config_hash["GIT_TAG_PREFIX"] || ""
        version = sub(VersionFile).current
        "%s%s" % [prefix, version]
      end

    end

  end
end
