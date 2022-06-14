libhelium_sources = []
libhelium_sources += files(
    'Main.vala',
    'Models/Application.vala',
    'Models/Bin.vala',
    'Models/Button.vala',
    'Models/Colors.vala',
    'Models/View.vala',
    'Models/Window.vala',
    'Utils/Desktop.vala',
    'Utils/Portal.vala',
    'Utils/Misc.vala',
    'Widgets/AboutWindow.vala',
    'Widgets/AppBar.vala',
    'Widgets/ApplicationWindow.vala',
    'Widgets/Badge.vala',
    'Widgets/Banner.vala',
    'Widgets/BottomBar.vala',
    'Widgets/Chip.vala',
    'Widgets/ContentBlock.vala',
    'Widgets/ContentBlockImage.vala',
    'Widgets/ContentBlockImageCluster.vala',
    'Widgets/ContentList.vala',
    'Widgets/Dialog.vala',
    'Widgets/DisclosureButton.vala',
    'Widgets/EmptyPage.vala',
    'Widgets/FillButton.vala',
    'Widgets/IconicButton.vala',
    'Widgets/MiniContentBlock.vala',
    'Widgets/ModifierBadge.vala',
    'Widgets/OutlineButton.vala',
    'Widgets/OverlayButton.vala',
    'Widgets/PillButton.vala',
    'Widgets/SideBar.vala',
    'Widgets/TextButton.vala',
    'Widgets/TintButton.vala',
    'Widgets/Toast.vala',
    'Widgets/ViewAux.vala',
    'Widgets/ViewDual.vala',
    'Widgets/ViewMono.vala',
    'Widgets/ViewSubTitle.vala',
    'Widgets/ViewSwitcher.vala',
    'Widgets/ViewTitle.vala',
    'Widgets/WelcomeScreen.vala',
    'Widgets/AlbumPage.vala',
    'Widgets/Album.vala'
)

# define all the names and versions
libhelium_gi_name = 'He'
libhelium_gi_version = '1'

libhelium_gi = libhelium_gi_name + '-' + libhelium_gi_version
libhelium_typelib = libhelium_gi + '.typelib'

include_dir = join_paths(
    get_option('prefix'),
    get_option('includedir')
)

# compile shared library, generate GIR, header, and vapi file
datadir    = get_option('datadir')
girdir     = get_option('datadir') / 'gir-1.0'
libdir     = get_option('libdir')
typelibdir = get_option('libdir')  / 'girepository-1.0'
vapidir    = get_option('datadir') / 'vapi'

libhelium = library(
    'libhelium-1',

    gresource,
    libhelium_sources,

    dependencies: [
        libhelium_deps,
        meson.get_compiler('c').find_library('m'),
        meson.get_compiler('vala').find_library('posix')
    ],

    vala_header: 'libhelium-1.h',
    vala_gir: 'He-1.gir',

    version: libhelium_gi_version,
    install: true,
    install_dir: [true, include_dir, girdir],
)

libhelium_vapi = gnome.generate_vapi(
         'libhelium-1',
         sources: 'He-1.gir',
        packages: [ 'gio-2.0', 'gtk4' ],
         install: true,
     install_dir: vapidir,
   metadata_dirs: [ meson.current_source_dir() ],
)

if get_option('introspection')
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
            join_paths(meson.current_build_dir(), 'He-1.gir'),
        ],
        input: libhelium,
        output: libhelium_typelib,
        depends: libhelium,
        install: true,
        install_dir: join_paths(get_option('libdir'), 'girepository-1.0'),
    )
endif

libhelium_dep = declare_dependency(
    dependencies: libhelium_deps,
    include_directories: [include_directories('.')],
    link_with: libhelium,
)

libhelium_pc = pkgconfig.generate(
    libhelium,
    name: 'libhelium',
    requires: libhelium_deps,
    description: 'tauOS\'s Application Framework',
    version: '1',
    url: 'https://github.com/tau-OS/libhelium',
)
