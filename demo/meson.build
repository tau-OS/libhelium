subdir('data')

conf = configuration_data()
conf.set_quoted('APP_ID', 'com.fyralabs.Helium1.Demo')
conf.set_quoted('VERSION', '1.8.0')
conf.set_quoted(
  'LOCALEDIR',
  join_paths(get_option('prefix'), get_option('localedir')),
)
configure_file(output: 'config.h', configuration: conf)

example_deps = libhelium_deps
example_deps += [
  libhelium_dep,
  dependency(
    'libbismuth-1',
    fallback: ['libbismuth', 'libbismuth_dep'],
    version: '>=1.0.0',
  ),
]
example_sources = helium_demo_resources
example_sources += files(
  'src/main.vala',
  'src/sections/avatar.vala',
  'src/sections/badges.vala',
  'src/sections/banner.vala',
  'src/sections/bottomsheet.vala',
  'src/sections/buttons.vala',
  'src/sections/chips.vala',
  'src/sections/colorpicker.vala',
  'src/sections/contentawarebin.vala',
  'src/sections/datepicker.vala',
  'src/sections/emptypage.vala',
  'src/sections/feedback.vala',
  'src/sections/groupedbutton.vala',
  'src/sections/menubutton.vala',
  'src/sections/overlaybutton.vala',
  'src/sections/progressbar.vala',
  'src/sections/slider.vala',
  'src/sections/splitbutton.vala',
  'src/sections/switch.vala',
  'src/sections/textfields.vala',
  'src/sections/timepicker.vala',
  'src/sections/tipview.vala',
  'src/sections/welcome.vala',
  'src/settings.vala',
  'src/window.vala',
)

executable(
  'com.fyralabs.Helium1.Demo',
  [blueprints_hack, example_sources],
  dependencies: example_deps,
  vala_args: [
    meson.project_source_root() + '/demo/src/config.vapi',
    '--gresourcesdir=demo/data/ui/',
    '--gresourcesdir', meson.current_build_dir() / 'data',
  ],
  install: true,
)
