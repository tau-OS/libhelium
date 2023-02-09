subdir('data')
subproject('blueprint-compiler')

conf = configuration_data()
conf.set_quoted('APP_ID', 'com.fyralabs.Helium1.Demo')
conf.set_quoted('VERSION', '1.2.5')
conf.set_quoted('LOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

example_deps = libhelium_deps
example_deps += dependency('libhelium-1')
example_deps += dependency('libbismuth-1', fallback: [ 'libbismuth', 'libbismuth_dep' ], version: '>=1.0.0')

example_sources = files(
	'src/main.vala',
	'src/window.vala',
	'src/settings.vala'
)

executable(
	'com.fyralabs.Helium1.Demo',
	helium_demo_resources,
	sources: example_sources,
	dependencies:  example_deps,
	vala_args: [meson.project_source_root() + '/demo/src/config.vapi'],
	install: true,
)
