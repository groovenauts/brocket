require 'spec_helper'

describe :test_gem do
  let(:dockerfile){ File.expand_path("../test_gem/Dockerfile", __FILE__) }
    
  describe BRocket::VersionFile do
    let(:version_obj) do
      obj = BRocket::VersionFile.new
      obj.options = {dockerfile: dockerfile}
      obj
    end
    it{ expect(version_obj.current).to eq "0.2.1" }
  end
end
