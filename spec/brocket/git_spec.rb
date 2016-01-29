require 'spec_helper'

describe BRocket::Git do

  let(:subject){ BRocket::Git.new }

  describe "Dockerfile-basic" do
    let(:filepath){ File.expand_path("../Dockerfiles/Dockerfile-git-tag", __FILE__) }
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

end
