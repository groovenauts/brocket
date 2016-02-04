require 'spec_helper'

describe :multi_app_proj do
  context "app1 with absolute path" do
    let(:dockerfile){ File.expand_path("../multi_app_proj/app1/docker/Dockerfile", __FILE__) }

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

  context "app1 with relative path" do
    let(:base_dir){ File.expand_path("../multi_app_proj/app1", __FILE__) }
    let(:docker_relpath){ "docker/Dockerfile" }

    around do |example|
      Dir.chdir(base_dir) do
        example.run
      end
    end
    before{ allow(BRocket).to receive(:user_pwd).and_return(base_dir) }

    describe BRocket::VersionFile do
      let(:version_obj) do
        obj = BRocket::VersionFile.new
        obj.options = {dockerfile: docker_relpath}
        obj
      end
      it{ expect(version_obj.current).to eq "1.2.1" }
    end

    describe BRocket::Git do
      let(:git_obj) do
        obj = BRocket::Git.new
        obj.options = {dockerfile: docker_relpath}
        obj
      end
      it{ expect(git_obj.version_tag).to eq "1.2.1" }
    end

    describe BRocket::Docker do
      let(:docker_obj) do
        obj = BRocket::Docker.new
        obj.options = {dockerfile: docker_relpath}
        obj
      end
      it{ expect(docker_obj.working_dir).to eq base_dir }
      it{ expect(docker_obj.config_filepath).to eq File.expand_path(docker_relpath, base_dir) }
      it{ expect(docker_obj.config_relpath ).to eq docker_relpath }
      it do
        expect(docker_obj).to receive(:sh).with("docker build -t old_app1:1.2.1 -f docker/Dockerfile .")
        docker_obj.build
      end
    end
  end

  context "app2 with relative path" do
    let(:base_dir){ File.expand_path("../multi_app_proj/app2", __FILE__) }
    # let(:docker_relpath){ "Dockerfile" }

    around do |example|
      Dir.chdir(base_dir) do
        example.run
      end
    end

    before{ allow(BRocket).to receive(:user_pwd).and_return(base_dir) }

    describe BRocket::VersionFile do
      let(:version_obj) do
        obj = BRocket::VersionFile.new
        # obj.options = {dockerfile: docker_relpath}
        obj
      end
      it{ expect(version_obj.current).to eq "0.1.0" }
      it do
        Dir.chdir(version_obj.working_dir) do
          expect(version_obj.current).to eq "0.1.0"
        end
      end
    end

    describe BRocket::Git do
      let(:git_obj) do
        obj = BRocket::Git.new
        # obj.options = {dockerfile: docker_relpath}
        obj
      end
      it{ expect(git_obj.version_tag).to eq "app2/0.1.0" }
      it do
        Dir.chdir(git_obj.working_dir) do
          expect(git_obj.version_tag).to eq "app2/0.1.0"
        end
      end
    end

    describe BRocket::Docker do
      let(:docker_obj) do
        obj = BRocket::Docker.new
        # obj.options = {dockerfile: docker_relpath}
        obj
      end
      before{ allow(docker_obj).to receive(:system).with("docker ps >/dev/null 2>/dev/null").and_return(true) }
      it{ expect(docker_obj.working_dir).to eq File.expand_path("..", base_dir) }
      it{ expect(docker_obj.config_filepath).to eq File.expand_path("Dockerfile", base_dir) }
      it{ expect(docker_obj.config_relpath ).to eq "app2/Dockerfile" }
      it do
        expect(docker_obj).to receive(:sh).with("docker build -t new_app2:0.1.0 -f app2/Dockerfile .")
        docker_obj.build
      end
    end
  end
end
