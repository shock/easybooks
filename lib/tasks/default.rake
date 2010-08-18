rspec_base = File.expand_path("#{RAILS_ROOT}/vendor/plugins/rspec/lib")
$LOAD_PATH.unshift(rspec_base) if File.exist?(rspec_base)
require 'spec/rake/spectask'
Rake::Task[:default].prerequisites.clear
desc "Run specs with rcov output"
Spec::Rake::SpecTask.new(:default) do |t|
  t.spec_opts = ['--options', "#{RAILS_ROOT}/spec/spec.opts"]
  t.spec_files = FileList['spec/**/*_spec.rb']
end
