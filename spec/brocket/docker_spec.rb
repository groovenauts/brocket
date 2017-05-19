require 'spec_helper'

describe BRocket::Docker do

  let(:subject){ BRocket::Docker.new }

  let(:image_name){ "groovenauts/rails-example" }
  let(:version){ "2.3.4" }

  let(:expected_options){ {"dockerfile"=>"Dockerfile"} }
  before do
    version_file = double(:version_file, current: version)
    allow(version_file).to receive(:options=).with(Hash)
    allow(BRocket::VersionFile).to receive(:new).and_return(version_file)
  end

  before{ allow(subject).to receive(:system).with("docker ps >/dev/null 2>/dev/null").and_return(true) }

  describe "Dockerfile-basic" do
    let(:filepath){ File.expand_path("../Dockerfiles/Dockerfile-basic", __FILE__) }
    before{ allow(BRocket).to receive(:user_pwd).and_return(File.dirname(filepath)) }

    before do
      allow(subject).to receive(:read_config_file).with(any_args).and_return(File.read(filepath))
    end

    describe :config do
      it{ expect(subject.config_hash).to eq({"IMAGE_NAME" => image_name}) }
      it do
        expect($stdout).to receive(:puts).with(YAML.dump(subject.config_hash))
        subject.config
      end
    end

    describe :build do
      it do
        expect(subject).to receive(:sh).with("docker build -t #{image_name}:#{version} .")
        subject.build
      end
    end

    describe :push do
      it do
        expect(subject).to receive(:sh).with("docker push #{image_name}:#{version}")
        subject.push
      end
    end
  end

  describe "Dockerfile-gcr" do
    let(:original_image_name){ "rails-example" }
    let(:gcr_image_name){ "asia.gcr.io/groovenauts/rails-example" }
    let(:filepath){ File.expand_path("../Dockerfiles/Dockerfile-gcr", __FILE__) }
    before{ allow(BRocket).to receive(:user_pwd).and_return(File.dirname(filepath)) }

    before do
      allow(subject).to receive(:read_config_file).with(any_args).and_return(File.read(filepath))
    end

    describe :push do
      it do
        expected_cmd = [
          "docker tag #{original_image_name}:#{version} #{gcr_image_name}:#{version}",
          "gcloud docker -- push #{gcr_image_name}:#{version}"
        ].join(' && ')
        expect(subject).to receive(:sh).with(expected_cmd)
        subject.push
      end
    end
  end

  describe "Dockerfile-push-extra-tag" do
    let(:original_image_name){ "rails-example" }
    let(:gcr_image_name){ "asia.gcr.io/groovenauts/rails-example" }
    let(:filepath){ File.expand_path("../Dockerfiles/Dockerfile-push-extra-tag", __FILE__) }
    before{ allow(BRocket).to receive(:user_pwd).and_return(File.dirname(filepath)) }
    before{ subject.options = {dockerfile: filepath} }
    let(:expected_options){ {dockerfile: filepath} }

    describe :push do
      it do
        expected_cmd = [
          "docker tag #{original_image_name}:#{version} #{gcr_image_name}:#{version}",
          "docker tag #{original_image_name}:#{version} #{gcr_image_name}:latest",
          "gcloud docker -- push #{gcr_image_name}:#{version}",
          "gcloud docker -- push #{gcr_image_name}:latest",
        ].join(' && ')
        expect(subject).to receive(:sh).with(expected_cmd)
        subject.push
      end
    end
  end

  describe "Dockerfile-working_dir" do
    let(:filepath){ File.expand_path("../Dockerfiles/Dockerfile-working_dir", __FILE__) }
    let(:expected_options){ {dockerfile: filepath} }
    before{ allow(BRocket).to receive(:user_pwd).and_return(File.dirname(filepath)) }

    before do
      allow(subject).to receive(:read_config_file).with(any_args).and_return(File.read(filepath))
    end

    describe :config do
      it{ expect(subject.config_hash).to eq({"IMAGE_NAME" => image_name, "WORKING_DIR" => ".."}) }
    end

    describe :build do
      it do
        dir = File.expand_path("../..", filepath)
        expect(Dir).to receive(:chdir).with(dir).and_yield
        expect(subject).to receive(:sh).with("docker build -t #{image_name}:#{version} -f Dockerfiles/Dockerfile-working_dir .")
        subject.options = {dockerfile: filepath}
        subject.build
      end
    end
  end


  describe "Dockerfile not found" do
    let(:filepath){ File.expand_path("../Dockerfiles/Dockerfile-noexist", __FILE__) }
    before{ allow(BRocket).to receive(:user_pwd).and_return(File.dirname(filepath)) }

    describe :config do
      it do
        expect{ subject.config }.to raise_error(/file not found/i)
      end
    end
  end

  describe "Dockerfile-hook" do
    let(:filepath){ File.expand_path("../Dockerfiles/Dockerfile-hook", __FILE__) }
    before{ allow(BRocket).to receive(:user_pwd).and_return(File.dirname(filepath)) }

    before do
      allow(subject).to receive(:read_config_file).with(any_args).and_return(File.read(filepath))
    end

    describe :config do
      it do
        expected = {
          "WORKING_DIR" => ".",
          "IMAGE_NAME" => image_name,
          "BEFORE_BUILD" => ["abc", "def ghi"],
          "AFTER_BUILD" => ["jkl", "mno"],
          "ON_BUILD_COMPLETE" => "foo bar",
          "ON_BUILD_ERROR" => "baz",
        }
        expect(subject.config_hash).to eq(expected)
      end
    end

    describe :build do
      it :success do
        expect(subject).to receive(:sh).with("abc")
        expect(subject).to receive(:sh).with("def ghi")
        expect(subject).to receive(:sh).with("docker build -t #{image_name}:#{version} .")
        expect(subject).to receive(:sh).with("foo bar")
        expect(subject).to receive(:sh).with("jkl")
        expect(subject).to receive(:sh).with("mno")
        subject.build
      end

      it :error do
        error_msg = "build error"
        expect(subject).to receive(:sh).with("abc")
        expect(subject).to receive(:sh).with("def ghi")
        expect(subject).to receive(:sh).with("docker build -t #{image_name}:#{version} .").and_raise(error_msg)
        expect(subject).to receive(:sh).with("baz") # not "foo bar"
        expect(subject).to receive(:sh).with("jkl")
        expect(subject).to receive(:sh).with("mno")
        expect{
          subject.build
        }.to raise_error(error_msg)
      end
    end

    describe :call_before_build do
      it do
        expect(Dir).to receive(:chdir).with(subject.working_dir).and_yield
        expect(subject).to receive(:sh).with("abc")
        expect(subject).to receive(:sh).with("def ghi")
        subject.call_before_build
      end
    end
    describe :call_after_build do
      it do
        expect(Dir).to receive(:chdir).with(subject.working_dir).and_yield
        expect(subject).to receive(:sh).with("jkl")
        expect(subject).to receive(:sh).with("mno")
        subject.call_after_build
      end
    end
  end

  describe "use_sudo_for_docker" do
    let(:filepath){ File.expand_path("../Dockerfiles/Dockerfile-basic", __FILE__) }
    before{ allow(BRocket).to receive(:user_pwd).and_return(File.dirname(filepath)) }
    before{ subject.options = {dockerfile: filepath} }

    context "auto and need sudo" do
      before{ subject.options = {use_sudo_for_docker: "auto"}.update(subject.options) }
      before{ allow(subject).to receive(:system).with("docker ps >/dev/null 2>/dev/null").and_return(false) }
      it :build do
        expect(subject).to receive(:sh).with("sudo docker build -t #{image_name}:#{version} -f Dockerfile-basic .")
        subject.build
      end
      it :push do
        expect(subject).to receive(:sh).with("sudo docker push #{image_name}:#{version}")
        subject.push
      end
    end

    context "auto and don't need sudo" do
      before{ subject.options = {use_sudo_for_docker: "auto"}.update(subject.options) }
      before{ allow(subject).to receive(:system).with("docker ps >/dev/null 2>/dev/null").and_return(true) }
      it :build do
        expect(subject).to receive(:sh).with("docker build -t #{image_name}:#{version} -f Dockerfile-basic .")
        subject.build
      end
      it :push do
        expect(subject).to receive(:sh).with("docker push #{image_name}:#{version}")
        subject.push
      end
    end

    context "true" do
      before{ subject.options = {use_sudo_for_docker: "true"}.update(subject.options) }
      before{ allow(subject).to receive(:system).with("docker ps >/dev/null 2>/dev/null").and_return(false) }
      it :build do
        expect(subject).to receive(:sh).with("sudo docker build -t #{image_name}:#{version} -f Dockerfile-basic .")
        subject.build
      end
      it :push do
        expect(subject).to receive(:sh).with("sudo docker push #{image_name}:#{version}")
        subject.push
      end
    end

    context "false" do
      before{ subject.options = {use_sudo_for_docker: "false"}.update(subject.options) }
      before{ allow(subject).to receive(:system).with("docker ps >/dev/null 2>/dev/null").and_return(true) }
      it :build do
        expect(subject).to receive(:sh).with("docker build -t #{image_name}:#{version} -f Dockerfile-basic .")
        subject.build
      end
      it :push do
        expect(subject).to receive(:sh).with("docker push #{image_name}:#{version}")
        subject.push
      end
    end
  end

end
