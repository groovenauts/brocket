require 'spec_helper'

describe BRocket::VersionFile do

  let(:subject){ BRocket::VersionFile.new }

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
      let(:git){ double(:git_for_guard_clean, guard_clean: true) }
      let(:git_for_commit     ){ double(:git_for_commit) }
      before do
        allow(BRocket::Git).to receive(:new).and_return(git)
        allow(git).to receive(:options=).with("dockerfile"=>"Dockerfile")
        allow(git).to receive(:commit).with("VERSION", instance_of(String))
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
