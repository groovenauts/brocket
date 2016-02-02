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

  describe :verbose do
    let(:msg){ "FOOO" }
    it "without verbose" do
      expect(BRocket.logger).not_to receive(:debug).with(msg)
      subject.verbose(msg)
    end
    it "without verbose" do
      subject.options = {verbose: true}
      called = false
      expect(BRocket.logger).to receive(:debug) do |actual_msg|
        expect(actual_msg.strip).to match /#{msg}/
        called = true
      end
      subject.verbose(msg)
      expect(called).to be_truthy
    end
  end
end
