module FileLoader
  def read_file(path)
    File.exist?(path) ? YAML.load_file(path) : []
  end

  def save_in_file(data, path)
    File.open(path, 'w') { |f| f.write data.to_yaml }
  end
end
