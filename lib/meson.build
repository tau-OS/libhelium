libhelium_sources = []
libhelium_sources += files(
    'Utils/Desktop.vala',
    'Utils/Portal.vala',
    'Models/Application.vala',
    'Models/Button.vala',
    'Models/Colors.vala',
    'Widgets/AppBar.vala',
    'Widgets/BottomBar.vala',
    'Widgets/ContentBlock.vala',
    'Widgets/DisclosureButton.vala',
    'Widgets/FillButton.vala',
    'Widgets/IconicButton.vala',
    'Widgets/OutlineButton.vala',
    'Widgets/OverlayButton.vala',
    'Widgets/PillButton.vala',
    'Widgets/TintButton.vala',
    'Widgets/TextButton.vala',
    'Widgets/ViewTitle.vala',
    'Widgets/ContentBlock.vala',
    'Widgets/ContentBlockImage.vala',
    'Widgets/MiniContentBlock.vala',
    'Widgets/ContentBlockImages.vala',
    'Widgets/Badge.vala',
    'Widgets/ModifierBadge.vala',
    'Widgets/Chip.vala',
    'Widgets/SideBar.vala',
    'Widgets/ViewSubTitle.vala',
)

# define all the names and versions
libhelium_gi_name = 'libhelium'
libhelium_gi_version = '1.0'

libhelium_gi = libhelium_gi_name + '-' + libhelium_gi_version
libhelium_typelib = libhelium_gi + '.typelib'

include_dir = join_paths(
    get_option('prefix'),
    get_option('includedir'),
    meson.project_name()
)

# compile shared library, generate GIR, header, and vapi file
datadir    = get_option('datadir')
libdir     = get_option('libdir')
girdir     = get_option('datadir') / 'gir-1.0'
typelibdir = get_option('libdir')  / 'girepository-1.0'
vapidir    = get_option('datadir') / 'vapi'

libhelium = library(
    libhelium_gi, 
    gresource,

    libhelium_sources,

    dependencies: [
        libhelium_deps,
        meson.get_compiler('c').find_library('m'),
        meson.get_compiler('vala').find_library('posix')
    ],

    vala_header: 'libhelium-1.h',
    vala_vapi: 'libhelium-1.vapi',
    vala_gir: 'libhelium-1.gir',

    version: libhelium_gi_version,
    install: true,
    install_dir: [true, include_dir, vapidir, girdir],
)

libhelium_dep = declare_dependency(
    link_with: libhelium,
    dependencies: libhelium_deps,
    include_directories: [include_directories('.')],
)