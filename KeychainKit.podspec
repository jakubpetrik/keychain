Pod::Spec.new do |s|
s.name = 'KeychainKit'
s.version = '0.0.1'
s.license = 'MIT'
s.summary = 'Yet another Keychain wrapper.'
s.homepage = 'https://github.com/jakubpetrik/keychainkit'
s.authors = { 'Jakub Petrík' => 'petrik@inloop.eu' }
s.source = { :git => 'https://github.com/jakubpetrik/keychainkit.git', :tag => s.version }

s.ios.deployment_target = '8.0'
s.osx.deployment_target = '10.9'

s.source_files = 'Sources/*.{h,swift}'
s.frameworks = 'Foundation'
end
