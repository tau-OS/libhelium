project('libhelium', ['c', 'vala'],
          version: '0.1.0',
    meson_version: '>= 0.59.0',
  default_options: [ 'warning_level=2',
                     'werror=false',
                   ],
)

gnome = import('gnome')

dependencies = [
    dependency('gtk4'),
    dependency('gio-2.0'),
]

sources = []

subdir('src')
helium = subproject('helium', default_options: ['gtk4=true', 'gtk3=false', 'shell=false'], required: true)

generate_gtk4_light = helium.get_variable('generate_gtk4_light')
generate_gtk4_dark = helium.get_variable('generate_gtk4_dark')

gresource = gnome.compile_resources(
    'gresource',
    'data' / 'gresource.xml',
    source_dir: [meson.current_build_dir() / 'subprojects' / 'helium' / 'Helium' / 'gtk-4.0', meson.current_source_dir()  / 'subprojects' / 'helium' / 'Helium' / 'gtk-4.0'],
    dependencies: [generate_gtk4_light, generate_gtk4_dark],
)


libhelium = shared_library('helium', gresource, sources,
		  vala_header: 'libhelium.h',
		  vala_vapi: 'libhelium.vapi',
                  dependencies: dependencies,
                  install: true,
                  install_dir: [true, true, true])


example_sources = sources + []

subdir('example')

# TODO: There has to be a way of just including this in the library and calling it a day
executable('libhelium-example', gresource, sources: example_sources, dependencies: dependencies, install: true)