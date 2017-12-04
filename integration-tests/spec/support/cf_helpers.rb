module CFHelpers
  def push_checker_app(name, port, domain=nil)
    cmd = "cf push #{name} -f #{File.join(__dir__, "service-binding-checker/manifest.yml")}"
    cmd << "-d #{domain}" if ENV["PORT"] == port.to_s
  end

  def delete_app(name)
    system("cf delete -f #{name}")
  end

  def cf_login(username, password)
    system("cf login -u #{username} -p #{password} --skip-ssl-validation")
  end

  def create_org(name)
    system("cf create-org #{name}")
  end

  def create_space(org, space)
    system("cf create-space -o #{org} #{space}")
  end

  def target(org, space)
    system("cf target -o #{org} -s #{space}")
  end

  def delete_org(name)
    system("cf delete-org -f #{name}")
  end
end

