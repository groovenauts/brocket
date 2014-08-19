require 'spec_helper'

describe Magellan::Build::Docker do

  let(:subject){ Magellan::Build::Docker.new }

  describe "Dockerfile-basic" do
    let(:filepath){ File.expand_path("../Dockerfiles/Dockerfile-basic", __FILE__) }
    let(:image_name){ "groovenauts/rails-example" }
    let(:version){ "2.3.4" }

    before do
      allow(subject).to receive(:read_file).with(any_args).and_return(File.read(filepath))
      allow(Magellan::Build::VersionFile).to receive(:current).and_return(version)
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

end
