# coding: utf-8
require 'spec_helper'

describe BRocket::VersionFile do

  let(:subject){ BRocket::VersionFile.new }
  let(:dockerfile){ File.expand_path("../Dockerfiles/Dockerfile-basic", __FILE__) }
  let(:version_file){ File.expand_path("../Dockerfiles/VERSION", __FILE__) }
  before{ subject.options = { dockerfile: dockerfile } }

  describe :init do
    it :without_arg do
      expect(subject).to receive(:write_file).with("0.0.1")
      subject.init
    end

    it :with_arg do
      expect(subject).to receive(:write_file).with("1.2.3")
      subject.init("1.2.3")
    end
  end

  describe :show do
    it do
      expect($stdout).to receive(:puts).with(File.read(version_file).strip)
      subject.show
    end

    context :invalid do
      let(:dockerfile){ File.expand_path("../Dockerfiles/Dockerfile-invalid-version", __FILE__) }
      it do
        expect{ subject.show }.to raise_error(BRocket::BuildError, /file not found/i)
      end
    end
  end

  describe :write_file do
    it do
      ver = "1.2.3"
      f = double(:mock_file)
      expect(File).to receive(:open).with(version_file, "w").and_yield(f)
      expect(f).to receive(:puts).with(ver)
      subject.send(:write_file, ver)
    end
  end

  {
    major: {
      without_arg: "2.2.3",
      with_arg: "5.2.3",
    },
    minor: {
      without_arg: "1.3.3",
      with_arg: "1.5.3",
    },
    bump: {
      without_arg: "1.2.4",
      with_arg: "1.2.5",
    },
  }.each do |method_name, patterns|

    describe method_name do
      let(:git){ subject.sub(BRocket::Git) }
      before do
        allow(BRocket::Git).to receive(:new).and_return(git)
        allow(git).to receive(:guard_clean)
        expect(git).to receive(:sh).with(/git add #{version_file} && git commit -m \".+\"/)
      end
      it :without_arg do
        allow(subject).to receive(:read_file).and_return("1.2.3")
        expect(subject).to receive(:write_file).with(patterns[:without_arg])
        subject.send(method_name)
      end

      it :with_arg do
        allow(subject).to receive(:read_file).and_return("1.2.3")
        expect(subject).to receive(:write_file).with(patterns[:with_arg])
        subject.send(method_name, "5")
      end
    end

  end

end
