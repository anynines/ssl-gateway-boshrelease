module CFHelpers
  def push_checker_app(name, port, domain=nil)
    Dir.chdir(File.join(__dir__, "service-binding-checker")) do
      ENV["PORT"] = port.to_s
      if domain
        system("cf push #{name} -d #{domain}")
      else
        system("cf push #{name}")
      end
    end
  end

  def delete_app(name)
    system("cf delete -f #{name}")
  end

  def cf_login(username, password)
    system("cf login -u #{username} -p #{password} --skip-ssl-validation")
  end

  def create_org(name)
    systen("cf create-org #{name}")
  end

  def create_space(org, space)
    systen("cf create-space -o #{org} #{space}")
  end

  def target(org, space)
    system("cf target -o #{org} -s #{space}")
  end

  def delete_org(name)
    system("cf delete-org -f #{name}")
  end
end

