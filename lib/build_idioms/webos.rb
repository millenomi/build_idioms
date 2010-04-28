
require 'json'

module BuildIdioms
	class WebOS
		def self.mojo_application(*args)
			self.new(*args)
		end
		
		SETTINGS = [
			:configuration,
			:base_build_path,
			:sources_path,
			:app_identifier,
			:run_target
		]
		attr_accessor(*SETTINGS)
		
		def initialize(options = nil)
			options = options || {}

			be_default = true
			options.each do |k,v|
				case k
				when :default
					be_default = v
				when :base_build_path
					@base_build_path = File.expand_path(v)
				when :sources_path
					@sources_path = File.expand_path(v)
				when :app_identifier
					@app_identifier = v
				when :run_target
					@run_target = v
				end
			end
			
			task :default => [:build] if be_default
			
			@run_target ||= ENV['ILABS_WEBOS_RUN_TARGET'] || ENV['ON']
			@run_target = nil if @run_target == 'any'
			
			@configuration ||= ENV['ILABS_configuration'] || 'debug'
			@base_build_path ||= ENV['ILABS_BASE_BUILD_PATH'] || File.expand_path("./Build-#{@configuration}")
			@sources_path ||= File.expand_path('.')
			
			unless @app_identifier
				manifest = File.join(@sources_path, 'appinfo.json');
				j = nil
				File.open(manifest, 'r') do |f|
					j = JSON::load(f)
				end
				
				@app_identifier = j['id']
			end
			
			raise "Cannot find the app identifier for application at path #{@sources_path} -- specify it in your Rakefile or fix appinfo.json" unless @app_identifier
			
			task :build do |t|
				mkdir_p self.base_build_path
				sh 'palm-package', '-o', self.base_build_path, self.sources_path
			end
			
			task :clean do |t|
				FileList[File.join(self.base_build_path, "#{self.app_identifier}*.ipk")].each do |p|
					rm p
				end
			end
			
			task :dump_settings do |t|
				SETTINGS.each do |s|
					puts " Setting: #{s} = #{self.send s}"
				end
			end
			
			task :install => [:build]
			task :install do |t|
				ipk = FileList[File.join(self.base_build_path, "#{self.app_identifier}*.ipk")][0]
				raise "No IPK file in build directory" unless ipk
				
				args = ['palm-install']
				if self.run_target
					args << '-d' << self.run_target
				end
				
				args << ipk
				sh(*args)
			end
			
			task :run => [:install]
			task :run do |t|
				args = ['palm-launch']
				if self.run_target
					args << '-d' << self.run_target
				end
				
				args << self.app_identifier
				sh(*args)
			end
			
			task :quit do |t|
				args = ['palm-launch']
				if self.run_target
					args << '-d' << self.run_target
				end
				
				args << '-c' << self.app_identifier
				sh(*args)
			end
			
			task :restart => [:quit, :run]
			
			task :uninstall => [:quit]
			task :uninstall do |t|
				args = ['palm-install']
				if self.run_target
					args << '-d' << self.run_target
				end
				
				args << '-r' << self.app_identifier
				sh(*args)
			end
		end
		
	end
end
