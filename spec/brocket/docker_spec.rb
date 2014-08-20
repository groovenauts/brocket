require 'spec_helper'

describe BRocket::Docker do

  let(:subject){ BRocket::Docker.new }

  describe "Dockerfile-basic" do
    let(:filepath){ File.expand_path("../Dockerfiles/Dockerfile-basic", __FILE__) }
    let(:image_name){ "groovenauts/rails-example" }
    let(:version){ "2.3.4" }

    before do
      allow(subject).to receive(:read_config_file).with(any_args).and_return(File.read(filepath))
      allow_any_instance_of(BRocket::VersionFile).to receive(:current).and_return(version)
    end

    describe :config do
      it{ expect(subject.config_hash).to eq({"IMAGE_NAME" => image_name}) }
    end

    describe :build do
      it do
        expect(subject).to receive(:sh).with("docker build -t #{image_name}:#{version} .")
        subject.build
      end
    end
  end


  describe "Dockerfile-basic" do
    let(:filepath){ File.expand_path("../Dockerfiles/Dockerfile-hook", __FILE__) }
    let(:image_name){ "groovenauts/rails-example" }
    let(:version){ "2.3.4" }

    before do
      allow(subject).to receive(:read_config_file).with(any_args).and_return(File.read(filepath))
      allow_any_instance_of(BRocket::VersionFile).to receive(:current).and_return(version)
    end

    describe :config do
      it do
        expected = {
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
  end

end
