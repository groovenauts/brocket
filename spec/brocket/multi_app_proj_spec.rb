require 'spec_helper'

describe :multi_app_proj do
  context "app1 with absolute path" do
    let(:dockerfile){ File.expand_path("../multi_app_proj/app1/docker/Dockerfile", __FILE__) }
    let(:version_filepath){ File.expand_path("../multi_app_proj/app1/docker/VERSION.txt", __FILE__) }
    
    describe BRocket::VersionFile do
      let(:version_obj) do
        obj = BRocket::VersionFile.new
        obj.options = {dockerfile: dockerfile}
        obj
      end
      it{ expect(version_obj.current).to eq "1.2.1" }
    end

    describe BRocket::Git do
      let(:git_obj) do
        obj = BRocket::Git.new
        obj.options = {dockerfile: dockerfile}
        obj
      end
      it{ expect(git_obj.version_tag).to eq "1.2.1" }
    end
  end

  context "app2 with absolute path" do
    let(:dockerfile){ File.expand_path("../multi_app_proj/app2/Dockerfile", __FILE__) }
    let(:version_filepath){ File.expand_path("../multi_app_proj/app2/VERSION", __FILE__) }
    
    describe BRocket::VersionFile do
      let(:version_obj) do
        obj = BRocket::VersionFile.new
        obj.options = {dockerfile: dockerfile}
        obj
      end
      it{ expect(version_obj.current).to eq "0.1.0" }
    end

    describe BRocket::Git do
      let(:git_obj) do
        obj = BRocket::Git.new
        obj.options = {dockerfile: dockerfile}
        obj
      end
      it{ expect(git_obj.version_tag).to eq "app2/0.1.0" }
    end
  end
end
