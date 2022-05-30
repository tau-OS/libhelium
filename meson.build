project('libhelium', ['c', 'vala'],
          version: '0.1.0',
    meson_version: '>= 0.59.0',
  default_options: [ 'warning_level=2',
                     'werror=false',
                   ],
)


dependencies = [
    dependency('gtk4'),
    dependency('gio-2.0'),
]


sources = []

subdir('src')

libhelium = shared_library('helium', sources,
		  vala_header: 'libhelium.h',
		  vala_vapi: 'libhelium.vapi',
                  dependencies: dependencies,
                  install: true,
                  install_dir: [true, true, true])


example_sources = sources + []

subdir('example')

executable('libhelium-example', sources: example_sources, dependencies: dependencies, install: true)