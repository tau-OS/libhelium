blueprints = custom_target('blueprints',
  input: files(
    'ui/window.blp',
    'ui/menu.blp',
    'ui/settings.blp',
  ),
  install: true,
  install_dir: '.',
  output: '.',
  command: [find_program('blueprint-compiler'), 'batch-compile', '@OUTPUT@', '@CURRENT_SOURCE_DIR@', '@INPUT@'],
)

install_data(
  'libhelium.svg',
  install_dir: get_option('datadir') / 'icons' / 'hicolor' / 'scalable' / 'apps'
)

install_data(\
  'libhelium-symbolic.svg',
  install_dir: get_option('datadir') / 'icons' / 'hicolor' / 'symbolic' / 'apps'
)

helium_demo_resources = gnome.compile_resources(
  'helium-demo-resources',
  'co.tauos.Helium1.Demo.gresources.xml',
  source_dir: meson.current_build_dir(),
  c_name: 'he',
  dependencies: blueprints,
  install_dir: get_option('datadir') / meson.project_name(),
)

desktop_file = i18n.merge_file(
  input: 'co.tauos.Helium1.Demo.desktop.in',
  output: 'co.tauos.Helium1.Demo.desktop',
  type: 'desktop',
  po_dir: '../../po',
  install: true,
  install_dir: get_option('datadir') / 'applications'
)

desktop_utils = find_program('desktop-file-validate', required: false)
if desktop_utils.found()
  test('Validate desktop file', desktop_utils,
    args: [desktop_file]
  )
endif