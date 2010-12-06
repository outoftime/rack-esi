Gem::Specification.new do |spec|
  spec.name = 'rack-esi-hpricot'
  spec.version = '0.1.9.1'
  spec.platform = 'ruby'
  spec.summary = 'Rack middleware for Edge-Side Includes, using Hpricot for XML parsing'
  spec.files = Dir.glob(File.join(File.dirname(__FILE__), 'lib/**/*.rb')) <<
    'README.markdown' << 'COPYING.txt'
  spec.add_dependency 'hpricot'
end
