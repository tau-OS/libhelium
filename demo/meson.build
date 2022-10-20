subdir('data')
subproject('blueprint-compiler')

conf = configuration_data()
conf.set_quoted('APP_ID', 'co.tauos.Helium1.Demo')
conf.set_quoted('VERSION', '1.0.0')
conf.set_quoted('LOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

example_sources = files(
	'src/main.vala',
	'src/window.vala',
	'src/settings.vala'
)

executable(
	'co.tauos.Helium1.Demo',
	helium_demo_resources,
	sources: example_sources,
	dependencies:  libhelium_dep,
	vala_args: [meson.project_source_root() + '/demo/src/config.vapi'],
	install: true,
)
