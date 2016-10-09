module.exports = function(grunt) {
	grunt.config.set('coffeelint', {
		dev : {
			files : {
				src : ['api/**/*.coffee', 'assets/js/*.coffee', 'config/**/*.coffee', 'tasks/**/*.coffee', '*.coffee']
			},
			options : {
				configFile : 'coffeelint.json'
			}
		}
	});

	grunt.loadNpmTasks('grunt-coffeelint');
}
