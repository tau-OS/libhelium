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
libhelium_gi_name = 'helium'
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
    meson.project_name(), gresource,

    libhelium_sources,

    dependencies: [
        libhelium_deps,
        meson.get_compiler('c').find_library('m'),
        meson.get_compiler('vala').find_library('posix')
    ],

    version: meson.project_version(),
    install: true,
    install_dir: [true, include_dir, true],
)

libhelium_gir = gnome.generate_gir(libhelium,
                 sources: libhelium_sources,
               nsversion: '1',
               namespace: 'He',
         export_packages: 'libhelium-1',
               link_with: libhelium,
                includes: ['Gio-2.0', 'Gtk-4.0'],
                 install: true,
         install_dir_gir: girdir,
     install_dir_typelib: typelibdir,
)

libhelium_vapi = gnome.generate_vapi('libhelium-1',
             sources: libhelium_gir[0],
            packages: [ 'gio-2.0', 'gtk4' ],
             install: true,
         install_dir: vapidir,
       metadata_dirs: [ meson.current_source_dir() ],
)

libhelium_dep = declare_dependency(
    link_with: libhelium,
    dependencies: libhelium_deps,
    include_directories: [include_directories('.')],
)