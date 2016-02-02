require 'spec_helper'

describe BRocket::Base do

  let(:subject){ BRocket::Base.new }

  describe :sh do
    let(:cmd){ 'echo "FOO"' }
    it "without dryrun" do
      expect(LoggerPipe).to receive(:run).with(BRocket.logger, cmd, dry_run: nil)
    end
    it "with dryrun" do
      subject.options = {dryrun: true}
      expect(LoggerPipe).to receive(:run).with(BRocket.logger, cmd, dry_run: true)
    end

    after do
      subject.sh(cmd)
    end
  end
end
