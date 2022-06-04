valadoc = find_program('valadoc')

valadoc_vala_dir = 'libhelium-1-vala'
valadoc_target = custom_target(
    'valadoc',
    command: [
        valadoc,
        '--pkg=glib-2.0',
        '--pkg=gio-2.0',
        '--pkg=gio-unix-2.0',
        '--pkg=gobject-2.0',
        '--pkg=gtk4',
        libhelium_sources,
        '--target-glib=' + glib_min_version,
        '--package-name=' + meson.project_name(),
        '--package-version=' + meson.project_version(),
        '--verbose',
        '--force',
        '--use-svg-images',
        '-o', join_paths(meson.current_build_dir(), valadoc_vala_dir),
    ],

    build_by_default: true,
    output: valadoc_vala_dir,
    depends: libhelium,
)