install_data(
  'libhelium.svg',
  install_dir: get_option('datadir') / 'icons' / 'hicolor' / 'scalable' / 'apps'
)

install_data(
  'libhelium-symbolic.svg',
  install_dir: get_option('datadir') / 'icons' / 'hicolor' / 'symbolic' / 'apps'
)

helium_demo_resources = gnome.compile_resources(
   'helium-demo-resources',
   'co.tauos.Helium1.Demo.gresources.xml',
   c_name: 'he',
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