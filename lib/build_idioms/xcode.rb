
module BuildIdioms
	class Xcode
		def self.project(*args)
			self.new(*args)
		end
		
		SETTINGS = [
			:sources_path,
			:configuration,
			:target,
			:parallelize,
			:sdk,
			:settings,
			:xcconfig,
			:developer_tools_path
		]
		attr_accessor(*SETTINGS)
		
		def initialize(options = {})
			@sources_path = File.expand_path(options[:sources_path]) if @sources_path
			@sources_path ||= File.expand_path('.') unless @sources_path
			
			@configuration = ENV['ILABS_XCODE_CONFIGURATION'] || options[:configuration]
			@target = options[:target]
			@parallelize = options[:parallelize]
			@settings = options[:settings]
			@sdk = ENV['ILABS_XCODE_SDK'] || options[:sdk]
			
			@xcconfig = ENV['ILABS_XCODE_XCCONFIG']
			@xcconfig ||= File.expand_path(options[:xcconfig]) if not @xcconfig and options[:xcconfig]
			
			@developer_tools_path = ENV['ILABS_XCODE_DEVELOPER_TOOLS_PATH']
			@developer_tools_path ||= File.expand_path(options[:developer_tools_path]) if not @developer_tools_path and options[:developer_tools_path]
			
			task :dump_settings do |t|
				SETTINGS.each do |s|
					puts " Setting: #{s} = #{self.send s}"
				end
			end
			
			task :build do |t|
				cd sources_path
				xc = xcodebuild_command_line
				xc << 'build'
				sh(*xc)
			end
			
			task :clean do |t|
				cd sources_path
				xc = xcodebuild_command_line
				xc << 'clean'
				sh(*xc)
			end
			
			task :install do |t|
				cd sources_path
				xc = xcodebuild_command_line
				xc << 'install'
				sh(*xc)
			end
			
			task :copy_sources do |t|
				cd sources_path
				xc = xcodebuild_command_line
				xc << 'installsrc'
				sh(*xc)
			end
		end
		
		def xcodebuild_command_line
			xcodebuild = if @developer_tools_path
				File.join(@developer_tools_path, 'usr', 'bin', 'xcodebuild')
			else
				'xcodebuild'
			end
			
			cmdline = [xcodebuild]
			cmdline << '-configuration' << configuration if configuration
			cmdline << '-target' << target if target
			cmdline << '-parallelizeTargets' if parallelize
			cmdline << '-sdk' << sdk if sdk
			cmdline << '-xcconfig' << xcconfig if xcconfig
			
			if settings.kind_of? Hash
				settings.each do |k,v|
					cmdline << "#{k}=#{v}"
				end
			end
			
			cmdline
		end
		
	end
end
