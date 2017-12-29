module BoshHelpers
  def deploy(manifest, iaas_config, external_secrets=nil, ops_file=nil)
    Dir.chdir(File.join(__dir__, "../../manifests")) do
      cmd = "bosh -n deploy -d ssl-gateway #{manifest} -l #{iaas_config}"
      cmd << " -o #{ops_file}" if ops_file
      cmd << " -l #{external_secrets}" if external_secrets
      system(cmd)
    end
  end

  def create_dev_release
    Dir.chdir(File.join(__dir__, "../../../")) do
      system("bosh -n create-release --force")
    end
  end

  def upload_last_dev_release
    Dir.chdir(File.join(__dir__, "../../../")) do
      ENV["RELEASE"] = `ls -1t dev_releases/ssl-gateway | sed -n 2p`
      system("bosh -n upload-release dev_releases/ssl-gateway/#{ENV["RELEASE"]}")
    end
  end

  def cleanup_all
    system("bosh -n clean-up --all")
  end

  def scp_read(node, path)
    system("bosh -n scp -d ssl-gateway --gw-user=vcap ssl-gateway/#{node}:#{path} /tmp/file")
    File.read("/tmp/file")
  end
end
