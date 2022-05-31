libhelium_sources = []
libhelium_sources += files(
	'Utils/Portal.vala',
	'Utils/Desktop.vala',
	'Models/Application.vala',
	'Models/Colors.vala',
	'Models/Button.vala',
	'Widgets/AppBar.vala',
	'Widgets/FillButton.vala',
	'Widgets/TintButton.vala',
	'Widgets/TextButton.vala',
	'Widgets/PillButton.vala',
	'Widgets/OutlineButton.vala',
	'Widgets/OverlayButton.vala',
	'Widgets/IconicButton.vala',
	'Widgets/DisclosureButton.vala',
	'Widgets/ViewTitle.vala',
	'Widgets/BottomBar.vala',
)

# define all the names and versions
libhelium_gi_name = 'libhelium'
libhelium_gi_version = '1.0'

libhelium_gi = libhelium_gi_name + '-' + libhelium_gi_version
libhelium_gir = libhelium_gi + '.gir'
libhelium_typelib = libhelium_gi + '.typelib'

include_dir = join_paths(
    get_option('prefix'),
    get_option('includedir'),
    meson.project_name()
)

# compile shared library, generate GIR, header, and vapi file
libhelium = library(
    meson.project_name(), gresource,

    libhelium_sources,

    dependencies: [
        libhelium_deps,
        meson.get_compiler('c').find_library('m'),
        meson.get_compiler('vala').find_library('posix')
    ],

    vala_header: 'libhelium-1.h',
    vala_vapi: 'libhelium-1.vapi',
    vala_gir: libhelium_gir,

    version: meson.project_version(),
    install: true,
    install_dir: [true, include_dir, true, true],
)

# typelib generation isn't automated yet
g_ir_compiler = find_program('g-ir-compiler')
custom_target(
        libhelium_typelib,
        command: [
            g_ir_compiler,
            '--shared-library',
            '@PLAINNAME@',
            '--output',
            '@OUTPUT@',
            join_paths(meson.current_build_dir(), libhelium_gir),
        ],
        input: libhelium,
        output: libhelium_typelib,
        depends: libhelium,
        install: true,
        install_dir: join_paths(get_option('libdir'), 'girepository-1.0'),
)

libhelium_dep = declare_dependency(
    link_with: libhelium,
    dependencies: libhelium_deps,
    include_directories: [include_directories('.')],
)