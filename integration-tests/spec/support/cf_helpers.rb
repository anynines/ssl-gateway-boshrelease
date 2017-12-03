module CFHelpers
  def push_checker_app(name, port, domain=nil)
    Dir.chdir(File.join(__dir__, "service-binding-checker")) do
      ENV["PORT"] = port
      if domain
        `cf push #{name} -d #{domain}`
      else
        `cf push #{name}`
      end
    end
  end

  def delete_app(name)
    `cf delete #{name}`
  end

  def cf_login(username, password, space, org)
    `cf login -o #{org} -s #{space} -u #{username} -p #{password} --skip-ssl-validation`
  end
end

RSpec.configure do |c|
  c.include CFHelpers
end