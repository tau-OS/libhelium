screenshot_gresources = gnome.compile_resources(
    'screenshot-gresources',
    'screenshot.gresource.xml'
)

screenshot = executable(
    'screenshot',
    'main.c',
    screenshot_gresources,
    hgresource,
    gresource,
    dependencies: [libhelium_dep],
)
