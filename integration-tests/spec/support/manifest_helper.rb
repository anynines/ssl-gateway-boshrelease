module ManifestHelpers
  def render_manifest(manifest, properties)
    b = binding
    properties.each { |key, value| b.local_variable_set(key, value) }
      
    manifest_path = File.join(__dir__, "../../manifests/#{manifest}")

    File.open(manifest_path, "w") do |f|  
      f.write(ERB.new(File.read(File.join(__dir__, "../../manifests/#{manifest}.erb"))).result(b))
    end
  end
end

