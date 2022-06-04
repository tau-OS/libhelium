toml_data = configuration_data()
toml_data.set('VERSION', meson.project_version())

config = configure_file(
  input: 'libhelium.toml.in',
  output: 'libhelium.toml',
  configuration: toml_data
)

dependency('gi-docgen', version: '>= 2021.1',
           fallback: ['gi-docgen', 'dummy_dep'],
           native: true,
           required: get_option('documentation'))
gidocgen = find_program('gi-docgen')

docs_dir = datadir / 'doc'

dir = 'libhelium-1'
target = custom_target(
    'gidocgen',
    command: [
        gidocgen,
        'generate',
        '--quiet',
        '--add-include-path=lib',
        '--config=@0@'.format(config),
        '--no-namespace-dir',
        '--content-dir=@0@'.format(meson.current_source_dir()),
        '--output-dir=@0@'.format(join_paths(meson.current_build_dir(), dir)),
        'lib/He-1.gir'
    ],

    build_by_default: true,
    output: dir,
    depends: libhelium,
    install: true,
    install_dir: docs_dir,
)