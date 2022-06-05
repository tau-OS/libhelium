docgen = find_program('valadoc', required: get_option('documentation'))

docs_dir = datadir / 'doc'

dir = 'libhelium-1'
target = custom_target(
    'valadoc',
    command: [
        docgen,
        '--pkg=gee-0.8',
        '--pkg=glib-2.0',
        '--pkg=gio-2.0',
        '--pkg=gio-unix-2.0',
        '--pkg=gobject-2.0',
        '--pkg=gtk4',
        '--pkg=posix',
        libhelium_sources,
        '--target-glib=' + glib_min_version,
        '--package-name=' + meson.project_name(),
        '--package-version=' + meson.project_version(),
        '--verbose',
        '--force',
        '--use-svg-images',
        '-o', join_paths(meson.current_build_dir())
    ],

    build_by_default: true,
    output: dir,
    depends: libhelium,
    install: true,
    install_dir: docs_dir,
)
