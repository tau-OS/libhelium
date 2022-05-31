project('libhelium', ['c', 'vala'],
          version: '1.0.0',
    meson_version: '>= 0.59.0',
  default_options: [ 'warning_level=2', 'buildtype=debugoptimized' ],
)

gnome = import('gnome')
i18n = import('i18n')

# Setup various paths that subdirectory meson.build files need
package_subdir = get_option('package_subdir') # When used as subproject
if package_subdir != ''
  datadir    = get_option('datadir') / package_subdir
  libdir     = get_option('libdir')  / package_subdir
  girdir     = get_option('datadir') / package_subdir / 'gir-1.0'
  typelibdir = get_option('libdir')  / package_subdir / 'girepository-1.0'
  vapidir    = get_option('datadir') / package_subdir / 'vapi'
else
  datadir    = get_option('datadir')
  libdir     = get_option('libdir')
  girdir     = get_option('datadir') / 'gir-1.0'
  typelibdir = get_option('libdir')  / 'girepository-1.0'
  vapidir    = get_option('datadir') / 'vala' / 'vapi'
endif

dependencies = [
    dependency('gtk4'),
    dependency('gio-2.0'),
]

sources = []

subdir('src')
helium = subproject(
            'tau-helium', 
            default_options: ['gtk4=true', 'gtk3=false', 'shell=false'],
            required: true
         )
helium_folder = 'subprojects/tau-helium/Helium/gtk-4.0'

generate_gtk4_light = helium.get_variable('generate_gtk4_light')
generate_gtk4_dark = helium.get_variable('generate_gtk4_dark')

gresource = gnome.compile_resources(
    'gresource',
    'data' / 'gresource.xml',
    source_dir: [meson.current_build_dir() / helium_folder,
                 meson.current_source_dir()  / helium_folder],
    dependencies: [generate_gtk4_light, generate_gtk4_dark],
)


libhelium = shared_library('helium', gresource, sources,
		  vala_header: 'libhelium.h',
		  vala_vapi: 'libhelium-1.vapi',
                  dependencies: dependencies,
                  install: true,
                  install_dir: [true, true, true])

if get_option('demo')
  subdir('example')
endif
