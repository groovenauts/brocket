require 'spec_helper'

require 'logger_pipe'

describe BRocket::Git do

  let(:subject){ BRocket::Git.new }

  describe "Dockerfile-basic" do
    let(:filepath){ File.expand_path("../Dockerfiles/Dockerfile-git-tag", __FILE__) }
    let(:version_path){ File.expand_path("../Dockerfiles/VERSION", __FILE__) }
    let(:image_name){ "groovenauts/rails-example" }
    let(:tag_prefix){ "containers/rails_example/" }
    let(:version){ "2.3.4" }

    before do
      docker = BRocket::Docker.new
      allow(BRocket::Docker).to receive(:new).and_return(docker)
      allow(docker).to receive(:read_config_file).with(any_args).and_return(File.read(filepath))

      version_file = double(:version_file)
      allow(BRocket::VersionFile).to receive(:new).and_return(version_file)
      allow(version_file).to receive(:options=)
      allow(version_file).to receive(:current).and_return(version)
    end

    describe :config do
      it do
        expect(subject.version_tag).to eq("containers/rails_example/2.3.4")
      end
    end
  end

  describe "Dockerfile-git-tag" do
    let(:filepath){ File.expand_path("../Dockerfiles/Dockerfile-git-tag", __FILE__) }
    let(:version_path){ File.expand_path("../Dockerfiles/VERSION", __FILE__) }
    before do
      subject.options = {dockerfile: filepath}
      allow(BRocket).to receive(:user_pwd).and_return(File.dirname(filepath))
    end

    describe :guard_clean do
      it :clean_and_commited do
        expect(subject).to receive(:sh).with("git diff --exit-code")
        expect(subject).to receive(:sh).with("git diff-index --quiet --cached HEAD")
        expect(subject).to receive(:success).with(an_instance_of(String))
        subject.guard_clean
      end

      context :error do
        it :clean_and_not_commited do
          expect(subject).to receive(:sh).with("git diff --exit-code")
          expect(subject).to receive(:sh).with("git diff-index --quiet --cached HEAD").and_raise(LoggerPipe::Failure.new("not committed", nil))
        end

        it :not_clean_and_commited do
          expect(subject).to receive(:sh).with("git diff --exit-code").and_raise(LoggerPipe::Failure.new("not clean", nil))
          allow(subject).to receive(:sh).with("git diff-index --quiet --cached HEAD")
        end

        it :not_clean_and_not_commited do
          expect(subject).to receive(:sh).with("git diff --exit-code").and_raise(LoggerPipe::Failure.new("not clean", nil))
          allow(subject).to receive(:sh).with("git diff-index --quiet --cached HEAD").and_raise(LoggerPipe::Failure.new("not committed", nil))
        end

        after do
          expect(subject).to receive(:error).with(an_instance_of(String))
          expect(subject).not_to receive(:success).with(an_instance_of(String))
          subject.guard_clean
        end
      end
    end

    describe :push do
      it :valid do
        expect(subject).to receive(:sh).with("git tag").and_return(%w[0.9.1 0.9.2].join("\n"))
        expect(subject).to receive(:sh).with("git tag -a -m \"Version containers/rails_example/1.0.0\" containers/rails_example/1.0.0")
        expect($stdout).to receive(:puts).with(/tagged containers\/rails_example\/1\.0\.0/i)
        expect(subject).to receive(:sh).with("git push")
        expect(subject).to receive(:sh).with("git push --tags")
        expect($stdout).to receive(:puts).with(/pushed/i)
        subject.push
      end
      it :already_tagged do
        expect(subject).to receive(:sh).with("git tag").and_return(%w[0.9.1 0.9.2 1.0.0 1.0.1].map{|v| "containers/rails_example/#{v}"}.join("\n"))
        expect($stderr).to receive(:puts).with(/tag .+ already .+ created/i)
        subject.push
      end

      context :error do
        before do
          expect(subject).to receive(:sh).with("git tag").and_return(%w[0.9.1 0.9.2].join("\n"))
        end

        it "do untagging on error at git tag" do
          expect(subject).to receive(:sh).
                              with("git tag -a -m \"Version containers/rails_example/1.0.0\" containers/rails_example/1.0.0").
                              and_raise(LoggerPipe::Failure.new("something wrong", nil))
          expect($stderr).to receive(:puts).with(/untagging/i)
          expect(subject).to receive(:sh).with("git tag -d containers/rails_example/1.0.0")
          expect{ subject.push }.to raise_error(LoggerPipe::Failure)
        end

        it "do untagging on error at git push" do
          expect(subject).to receive(:sh).with("git tag -a -m \"Version containers/rails_example/1.0.0\" containers/rails_example/1.0.0")
          expect($stdout).to receive(:puts).with(/tagged containers\/rails_example\/1\.0\.0/i)
          expect(subject).to receive(:sh).with("git push").
                              and_raise(LoggerPipe::Failure.new("something wrong", nil))
          expect($stderr).to receive(:puts).with(/untagging/i)
          expect(subject).to receive(:sh).with("git tag -d containers/rails_example/1.0.0")
          expect{ subject.push }.to raise_error(LoggerPipe::Failure)
        end
      end

    end
  end

end
