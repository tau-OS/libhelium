docgen = find_program('valadoc', required: get_option('valadoc'))

valadoc_dir = datadir / 'valadoc'

dir = 'valadoc'
valadoc_gir = 'He-1.gir'
valadoc = custom_target(
    'valadoc',
    command: [
        docgen,
        '--pkg=gee-0.8',
        '--pkg=glib-2.0',
        '--pkg=gio-2.0',
        '--pkg=gio-unix-2.0',
        '--pkg=gobject-2.0',
        '--pkg=gtk4',
        '--pkg=posix', libhelium_sources,
        '--target-glib=' + glib_min_version,
        '--package-name=libhelium-1', '--package-version=' + meson.project_version(),
        '--verbose',
        '--force',
        '--use-svg-images', # If documentation is true, we'll generate a GIR file with valadoc, independent of the main build. Path handling is a bit weird, so we move it after
        '--gir', 'He-1.gir',
        '-o', '@OUTPUT0@',
        '&&',
        'cp',
        join_paths(meson.project_source_root() / 'doc' / 'style.css'),
        meson.current_build_dir(),
        '&&',
        'mv',
        meson.current_build_dir() / '../He-1.gir',
        '@OUTPUT1@',
    ],

    build_by_default: true,
    output: [dir, valadoc_gir],
    depends: libhelium,
    install: true,
    install_dir: valadoc_dir,
)

if get_option('gidoc')
    gidocgen = find_program('gi-docgen', required: get_option('gidoc'))

    toml_data = configuration_data()
    toml_data.set('VERSION', meson.project_version())

    libhelium_toml = configure_file(
        input: 'libhelium.toml.in',
        output: 'libhelium.toml',
        configuration: toml_data,
    )

    doc_dir = datadir / 'doc'

    custom_target(
        'gidoc',
        input: [
            libhelium_toml,
            valadoc[1],
            meson.project_source_root() / 'assets' / 'Helium.svg',
        ],
        output: ['libhelium-@0@'.format(apiversion)],
        command: [
            gidocgen,
            'generate',
            # '--quiet',
            '--config=@INPUT0@',
            '--output-dir=@OUTPUT@',
            '--no-namespace-dir', '--content-dir=@0@'.format(
                meson.current_source_dir(),
            ),
            '@INPUT1@',
            '&&',
            'cp',
            '@INPUT2@',
            '@OUTPUT@',
        ],
        build_by_default: true,
        install: true,
        install_dir: doc_dir,
        depends: [valadoc],
    )
endif
