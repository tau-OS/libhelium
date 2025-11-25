blueprints = custom_target(
  'blueprints',
  input: files(
    'ui/sections/bottomsheet.blp',
    'ui/sections/contentawarebin.blp',
    'ui/sections/menubutton.blp',
    'ui/sections/overlaybutton.blp',
    'ui/sections/welcome.blp',
    'ui/settings.blp',
    'ui/window.blp',
  ),
  output: '.',
  depends: libhelium_typelib_file,
  command: [
    find_program('blueprint-compiler'),
    'batch-compile',
    '--typelib-path', '@BUILD_ROOT@/lib/',
    '@OUTDIR@',
    '@CURRENT_SOURCE_DIR@',
    '@INPUT@',
  ],
)

blueprints_hack = custom_target(
  'blueprints_hack',
  input: blueprints,
  output: 'blueprints_hack.vala',
  command: [find_program('touch'), '@OUTPUT@'],
)

install_data(
  'icons/com.fyralabs.Helium1.Demo.svg',
  install_dir: get_option('datadir') / 'icons' / 'hicolor' / 'scalable' / 'apps',
)

install_data(
  'icons/com.fyralabs.Helium1.Demo-symbolic.svg',
  install_dir: get_option('datadir') / 'icons' / 'hicolor' / 'symbolic' / 'apps',
)

helium_demo_resources = gnome.compile_resources(
  'helium-demo-resources',
  'com.fyralabs.Helium1.Demo.gresources.xml',
  c_name: 'he',
  dependencies: blueprints,
)

desktop_file = i18n.merge_file(
  input: 'com.fyralabs.Helium1.Demo.desktop.in',
  output: 'com.fyralabs.Helium1.Demo.desktop',
  type: 'desktop',
  po_dir: '../../po',
  install: true,
  install_dir: get_option('datadir') / 'applications',
)

desktop_utils = find_program('desktop-file-validate', required: false)
if desktop_utils.found()
  test('Validate desktop file', desktop_utils, args: [desktop_file])
endif
