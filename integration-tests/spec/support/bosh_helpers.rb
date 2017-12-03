module BoshHelper
  def deploy(manifest, iaas_config, external_secrets=nil, ops_file=nil)
    Dir.chdir(File.join(__dir__, "../../manifests")) do
      cmd = "bosh deploy -d ssl-gateway #{manifest} -l #{iaas_config}"
      cmd << " -o #{ops_file}" if ops_file
      cmd << " -l #{external_secrets}" if external_secrets
      system(cmd)
      system("bosh task")
    end
  end

  def create_dev_release
    Dir.chdir(File.join(__dir__, "../../../")) do
      `bosh create-release --force`
    end
  end

  def upload_last_dev_release
    Dir.chdir(File.join(__dir__, "../../../")) do
      ENV["RELEASE"] = `ls -1t dev_releases/ssl-gateway | sed -n 2p`
      `bosh upload-release dev_releases/ssl-gateway/#{ENV["RELEASE"]}`
      `bosh task`
    end
  end

  def cleanup_all
    system("bosh clean-up --all")
  end
end