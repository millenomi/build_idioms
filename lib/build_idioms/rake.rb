
module BuildIdioms
	class Xcode
		def self.rake(*args)
			self.new(*args)
		end
		
		SETTINGS = [
			:sources_path,
		]
		attr_accessor(*SETTINGS)
		
		def initialize(options = {})
			@sources_path = File.expand_path(options[:sources_path] || '.')
			
			task :dump_settings do |t|
				SETTINGS.each do |s|
					puts " Setting: #{s} = #{self.send s}"
				end
			end
			
			[
				:build,
				:clean,
				:install,
				:uninstall,
				:run,
				:quit
			].each do |tn|
				task tn do |t|
					cd @sources_path if @sources_path
					sh 'rake', tn.name
				end
			end
		end
	end
end
