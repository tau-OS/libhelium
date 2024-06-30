libhelium_sources = []
libhelium_sources += files(
    'Models/Application.vala',
    'Models/Bin.vala',
    'Models/Button.vala',
    'Models/ButtonContent.vala',
    'Models/Colors.vala',
    'Models/Schemes/Content.vala',
    'Models/Schemes/Default.vala',
    'Models/Schemes/Monochromatic.vala',
    'Models/Schemes/Muted.vala',
    'Models/Schemes/Salad.vala',
    'Models/Schemes/Scheme.vala',
    'Models/Schemes/SchemeFactory.vala',
    'Models/Schemes/Vibrant.vala',
    'Models/StyleManager.vala',
    'Models/View.vala',
    'Models/Window.vala',
    'Utils/Color.vala',
    'Utils/Color/ARGB.vala',
    'Utils/Color/CAM16.vala',
    'Utils/Color/GdkRGBA.vala',
    'Utils/Color/HCT/CriticalPlanes.vala',
    'Utils/Color/HCT/HCT.vala',
    'Utils/Color/HCT/HCTSolver.vala',
    'Utils/Color/Hexcode.vala',
    'Utils/Color/LAB.vala',
    'Utils/Color/LCH.vala',
    'Utils/Color/RGB.vala',
    'Utils/Color/XYZ.vala',
    'Utils/Desktop.vala',
    'Utils/Ensor/Ensor.vala',
    'Utils/Ensor/Quantize/Quantizer.vala',
    'Utils/Ensor/Quantize/QuantizerCelebi.vala',
    'Utils/Ensor/Quantize/QuantizerMap.vala',
    'Utils/Ensor/Quantize/QuantizerResult.vala',
    'Utils/Ensor/Quantize/QuantizerWsmeans.vala',
    'Utils/Ensor/Quantize/QuantizerWu.vala',
    'Utils/Ensor/Score.vala',
    'Utils/Math.vala',
    'Utils/Misc.vala',
    'Utils/Portal.vala',
    'Utils/ViewingConditions.vala',
    'Widgets/AboutWindow.vala',
    'Widgets/AppBar.vala',
    'Widgets/ApplicationWindow.vala',
    'Widgets/Avatar.vala',
    'Widgets/Badge.vala',
    'Widgets/Banner.vala',
    'Widgets/BottomBar.vala',
    'Widgets/Chip.vala',
    'Widgets/ChipGroup.vala',
    'Widgets/ContentBlock.vala',
    'Widgets/ContentBlockImage.vala',
    'Widgets/ContentBlockImageCluster.vala',
    'Widgets/ContentList.vala',
    'Widgets/DatePicker.vala',
    'Widgets/Dialog.vala',
    'Widgets/DisclosureButton.vala',
    'Widgets/Divider.vala',
    'Widgets/EmptyPage.vala',
    'Widgets/FillButton.vala',
    'Widgets/IconicButton.vala',
    'Widgets/MiniContentBlock.vala',
    'Widgets/ModifierBadge.vala',
    'Widgets/NavigationRail.vala',
    'Widgets/NavigationSection.vala',
    'Widgets/OutlineButton.vala',
    'Widgets/OverlayButton.vala',
    'Widgets/PillButton.vala',
    'Widgets/ProgressBar.vala',
    'Widgets/SegmentedButton.vala',
    'Widgets/SettingsList.vala',
    'Widgets/SettingsPage.vala',
    'Widgets/SettingsRow.vala',
    'Widgets/SettingsWindow.vala',
    'Widgets/SideBar.vala',
    'Widgets/Slider.vala',
    'Widgets/Switch.vala',
    'Widgets/SwitchBar.vala',
    'Widgets/Tab.vala',
    'Widgets/TabPage.vala',
    'Widgets/TabSwitcher.vala',
    'Widgets/TextButton.vala',
    'Widgets/TextField.vala',
    'Widgets/TimePicker.vala',
    'Widgets/TintButton.vala',
    'Widgets/Toast.vala',
    'Widgets/ViewAux.vala',
    'Widgets/ViewChooser.vala',
    'Widgets/ViewDual.vala',
    'Widgets/ViewMono.vala',
    'Widgets/ViewSubTitle.vala',
    'Widgets/ViewSwitcher.vala',
    'Widgets/ViewTitle.vala',
    'Widgets/WelcomeScreen.vala',
    'Config.vapi',
    'Main.vala',
)

# define all the names and versions
libhelium_gi_name = 'He'
libhelium_gi_version = '1'

libhelium_gi = libhelium_gi_name + '-' + libhelium_gi_version
libhelium_gir = libhelium_gi + '.gir'
libhelium_typelib = libhelium_gi + '.typelib'

include_dir = join_paths(get_option('prefix'), get_option('includedir'))

# compile shared library, generate GIR, header, and vapi file
datadir = get_option('datadir')
libdir = get_option('libdir')
typelibdir = get_option('libdir') / 'girepository-1.0'

resources = [
    hgresource,
]

if get_option('stylesheet')
    resources += gresource
endif

config = configuration_data()
config.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config.set_quoted(
    'LOCALEDIR',
    join_paths(get_option('prefix'), get_option('localedir')),
)

configure_file(
    output: 'config.h',
    configuration: config,
)

libhelium = library(
    'libhelium-1',

    resources,
    libhelium_sources,

    dependencies: [
        libhelium_deps,
        dependency('gio-2.0', version: '>=' + glib_min_version),
        meson.get_compiler('c').find_library('m'),
        meson.get_compiler('vala').find_library('posix'),
    ],

    vala_gir: libhelium_gir,
    vala_header: 'libhelium-1.h',
    vala_vapi: 'libhelium-1.vapi',

    vala_args: libhelium_vala_args,
    c_args: libhelium_c_args,

    version: libhelium_gi_version,
    install: true,
    install_dir: [true, include_dir, true, true],
    name_prefix: '',
)

pkg = import('pkgconfig')
pkg.generate(
    libhelium,
    requires: ['gtk4'],
    description: 'tauOS\'s Application Framework',
    url: 'https://github.com/tau-OS/libhelium',
)

if get_option('introspection')
    # typelib generation isn't automated yet
    g_ir_compiler = find_program('g-ir-compiler')
    libhelium_typelib_file = custom_target(
        libhelium_typelib,
        command: [
            g_ir_compiler,
            '--shared-library=@PLAINNAME@',
            '--output=@OUTPUT@',
            join_paths(
                meson.current_build_dir(),
                libhelium_gir,
            ),
        ],
        input: libhelium,
        output: libhelium_typelib,
        depends: libhelium,
        install: true,
        install_dir: join_paths(get_option('libdir'), 'girepository-1.0'),
    )
endif

libhelium_dep = declare_dependency(
    dependencies: [libhelium_deps],
    include_directories: [include_directories('.')],
    link_with: libhelium,
)