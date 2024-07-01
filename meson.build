project(
    'libhelium',
    'vala',
    'c',
    license: 'GPL-3-or-later',
    meson_version: '>= 0.56.0',
    version: '1.8.12',
    default_options: [
        'warning_level=1',
        'buildtype=debugoptimized',
        'c_std=gnu11',
    ],
)

version_arr = meson.project_version().split('-')[0].split('.')
helium_version_major = version_arr[0].to_int()
apiversion = helium_version_major.to_string()

gnome = import('gnome')
fs = import('fs')

libhelium_c_args = ['-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name())]
libhelium_vala_args = ['--abi-stability']

vala_os_arg = ['--define=LINUX']
glib_min_version = '2.50'
gio_os_dep = dependency('gio-unix-2.0', version: '>=' + glib_min_version)

add_project_arguments(
    vala_os_arg,
    '--target-glib=' + glib_min_version,
    language: ['vala'],
)

libhelium_deps = [
    dependency('gio-2.0', version: '>=' + glib_min_version),
    gio_os_dep,
    dependency('glib-2.0', version: '>=' + glib_min_version),
    dependency('gobject-2.0', version: '>=' + glib_min_version),
    dependency('gee-0.8'),
]

# NOTE(lexisother): Call upon the antichrist for this is the worst thing this
# organisation has seen in a Meson script.
gtk4_12 = dependency(
    'gtk4',
    version: '>=4.12',
    required: false,
)
valadoc_flags = []
if gtk4_12.found()
    gtk4 = dependency('gtk4', version: '>=4.12')
    valadoc_flags += '--define=GTK4_IS_12'
    add_project_arguments('--define=GTK4_IS_12', language: ['vala'])
else
    gtk4 = dependency('gtk4', version: '>=4.4')
endif
libhelium_deps += gtk4

pkgconfig = import('pkgconfig')
i18n = import('i18n')

if get_option('stylesheet')
    helium = subproject(
        'tau-helium',
        default_options: ['gtk4=true', 'shell=false'],
        required: true,
    )
    generate_gtk4_light = helium.get_variable('generate_gtk4_light')
    generate_gtk4_dark = helium.get_variable('generate_gtk4_dark')

    gresource = gnome.compile_resources(
        'gresource',
        'data' / 'gresource.xml',
        source_dir: [
            fs.parent(generate_gtk4_light.full_path()),
            fs.parent(generate_gtk4_dark.full_path()),
            fs.parent(helium.get_variable('assets_dir')),
        ],
        dependencies: [generate_gtk4_light, generate_gtk4_dark],
    )

    libhelium_vala_args += '--define=BUNDLED_STYLESHEET'
endif

hgresource = gnome.compile_resources(
    'he-gresource',
    'data' / 'he.gresource.xml',
    source_dir: 'data',
)


subdir('lib')
subdir('po')

if get_option('demo')
    subproject('blueprint-compiler', required: false)
    subdir('demo')
endif

if get_option('gidoc') or get_option('valadoc')
    subdir('doc')
endif

# GSettings schemas, merged from tau-gsettings-schemas since
# it's now standard for all Helium-based apps.

settings_schemas = ['data/com.fyralabs.desktop.appearance.gschema.xml']

gnome.compile_schemas(depend_files: files(settings_schemas))

schemas_dir = get_option('prefix') / get_option('datadir') / 'glib-2.0' / 'schemas'

install_data(settings_schemas, install_dir: schemas_dir)

meson.add_install_script('glib-compile-schemas', schemas_dir)


# end schema stuff
