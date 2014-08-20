require "brocket"

module BRocket
  class Git < Base

    desc "guard_clean", "Raise error if some difference exists."
    def guard_clean
      clean? && committed? or error("There are files that need to be committed first. Run `git status`")
      success("[git guard_clean] OK")
    end

    desc "push", "push commit and tag it"
    def push
      info("[git push] starting")
      tag_version { git_push } unless already_tagged?
      success("[git push] OK")
    end

    no_commands do

      def commit(filepath, msg)
        sh("git add #{filepath} && git commit -m \"#{msg}\"")
      end

      def clean?
        sh_with_code("git diff --exit-code")[1] == 0
      end

      def committed?
        sh_with_code("git diff-index --quiet --cached HEAD")[1] == 0
      end

      def tag_version
        sh "git tag -a -m \"Version #{version_tag}\" #{version_tag}"
        $stdout.puts "Tagged #{version_tag}."
        yield if block_given?
      rescue
        $stderr.puts "Untagging #{version_tag} due to error."
        sh_with_code "git tag -d #{version_tag}"
        raise
      end

      def git_push
        perform_git_push
        perform_git_push ' --tags'
        $stdout.puts "Pushed git commits and tags."
      end

      def perform_git_push(options = '')
        cmd = "git push #{options}"
        out, code = sh_with_code(cmd)
        error "Couldn't git push. `#{cmd}' failed with the following output:\n\n#{out}\n" unless code == 0
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
