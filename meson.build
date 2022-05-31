project(
    'helium-1',
    'vala', 'c',
    meson_version: '>= 0.48.2',
    version: '1.0.0'
)

gnome = import('gnome')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: ['c']
)

vala_os_arg = ['--define=LINUX']
glib_min_version = '2.50'
gio_os_dep = dependency('gio-unix-2.0', version: '>=' + glib_min_version)

add_project_arguments(
    vala_os_arg,
    '--abi-stability',
    '--hide-internal',
    '--target-glib=' + glib_min_version,
    language: ['vala']
)

libhelium_deps = [
    dependency('gio-2.0', version: '>=' + glib_min_version),
    gio_os_dep,
    dependency('glib-2.0', version: '>=' + glib_min_version),
    dependency('gobject-2.0', version: '>=' + glib_min_version),
    dependency('gtk4', version: '>=4.4'),
]

pkgconfig = import('pkgconfig')
i18n = import('i18n')

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

subdir('lib')
subdir('demo')