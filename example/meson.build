subdir('data')

conf = configuration_data()
conf.set_quoted('APP_ID', 'co.tauos.Helium1.Demo')
conf.set_quoted('VERSION', '1.0.0')
conf.set_quoted('LOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

example_sources = sources + [helium_demo_resources]
example_sources += files(
	'src/main.vala',
	'src/window.vala'
)

executable('libhelium-example', gresource, sources: example_sources, dependencies: dependencies, vala_args: [meson.project_source_root() + '/example/src/config.vapi'], install: true)