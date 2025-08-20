project('nrepellent_kai.lv2','c',version: '0.3.0',default_options: ['default_library=shared','c_std=c99'])

# Install folder
lv2_directory = join_paths(get_option('libdir'), 'lv2')
install_folder = join_paths(lv2_directory, meson.project_name())

# Sources to compile
common_src = ['src/signal_crossfade.c']
noise_repellent_src = ['plugins/nrepellent.c', 'src/noise_profile_state.c']

# Dependencies for noise repellent
lv2_dep = dependency('lv2', required: true)
# libspecbleach_dep = dependency('libspecbleach', fallback : ['libspecbleach', 'libspecbleach_dep'], default_options: ['default_library=static'], required: true)
libspecbleach_proj = subproject('libspecbleach', default_options: ['default_library=static'])
libspecbleach_dep = libspecbleach_proj.get_variable('libspecbleach_dep')
m_dep = meson.get_compiler('c').find_library('m', required: true)
all_dep = [lv2_dep,libspecbleach_dep,m_dep]

# Get the host operating system and cpu architecture
current_os = host_machine.system()
current_arch = build_machine.cpu_family()

# Shared c_args for libraries
lib_c_args = ['-fvisibility=hidden']

# Add default x86 and x86_64 optimizations
if current_arch == 'x86' or current_arch == 'x86_64' and current_os != 'darwin'
    lib_c_args += ['-msse','-msse2','-mfpmath=sse','-ffast-math','-fomit-frame-pointer','-fno-finite-math-only']
endif


# Configure extension for shared object
if current_os == 'darwin' #mac
    extension = '.dylib'
else #unix like (linux, bsd)   
    extension = '.so'
endif 
if current_os == 'windows' #windows
    extension = '.dll'
endif

# Getting version from project configuration or from git tags
version_array = meson.project_version().split('.')

git = find_program('git', native: true, required: false)
if version_array.length() == 0 and git.found()
    version_array = run_command('git', 'describe').stdout().strip().split('-')[0].split('.')
endif

data_conf = configuration_data()
data_conf.set('MAJOR_VERSION', version_array[0])
data_conf.set('MINOR_VERSION', version_array[1])
data_conf.set('MICRO_VERSION', version_array[2])
data_conf.set('PLUGIN_URI', 'https://github.com/lucianodato/noise-repellent#new')
data_conf.set('PLUGIN_NAME', 'Noise repellent')


# Build plugins with different frame sizes
frame_sizes = [1, 4, 16]
foreach fs : frame_sizes
    fs_str = fs.to_string()

    plugin_name = 'nrepellent_fs' + fs_str
    plugin_uri = 'https://github.com/lucianodato/noise-repellent#new_fs' + fs_str
    plugin_stereo_uri = 'https://github.com/lucianodato/noise-repellent-stereo#new_fs' + fs_str

    fs_lib_c_args = lib_c_args + [
        '-DFRAME_SIZE=' + fs_str + '.0f',
        '-DPLUGIN_URI="' + plugin_uri + '"',
        '-DPLUGIN_STEREO_URI="' + plugin_stereo_uri + '"',
    ]

    library(plugin_name,
        common_src,
        noise_repellent_src,
        c_args: fs_lib_c_args,
        name_prefix: '',
        dependencies: all_dep,
        install: true,
        install_dir: install_folder
    )

    ttl_conf = configuration_data()
    ttl_conf.merge_from(data_conf)
    ttl_conf.set('PLUGIN_URI', plugin_uri)
    ttl_conf.set('PLUGIN_NAME', 'Noise repellent (fs' + fs_str + ')')

    configure_file(
        input: join_paths('lv2ttl', 'nrepellent.ttl.in'),
        output: 'nrepellent_fs' + fs_str + '.ttl',
        configuration: ttl_conf,
        install: true,
        install_dir: install_folder
    )

    ttl_stereo_conf = configuration_data()
    ttl_stereo_conf.merge_from(data_conf)
    ttl_stereo_conf.set('PLUGIN_URI', plugin_stereo_uri)
    ttl_stereo_conf.set('PLUGIN_NAME', 'Noise repellent (fs' + fs_str + ')')

    configure_file(
        input: join_paths('lv2ttl', 'nrepellent#stereo.ttl.in'),
        output: 'nrepellent_fs' + fs_str + '#stereo.ttl',
        configuration: ttl_stereo_conf,
        install: true,
        install_dir: install_folder
    )
endforeach

# Generate manifest.ttl
manifest_content = '''
@prefix lv2:  <http://lv2plug.in/ns/lv2core#>.
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>.
'''

foreach fs : frame_sizes
    fs_str = fs.to_string()
    plugin_name = 'nrepellent_fs' + fs_str
    plugin_uri = 'https://github.com/lucianodato/noise-repellent#new_fs' + fs_str
    plugin_stereo_uri = 'https://github.com/lucianodato/noise-repellent-stereo#new_fs' + fs_str

    manifest_content += '''
<@0@>
  a lv2:Plugin;
  lv2:binary <@1@@LIB_EXT@> ;
  rdfs:seeAlso <@1@.ttl> .

<@2@>
  a lv2:Plugin;
  lv2:binary <@1@@LIB_EXT@> ;
  rdfs:seeAlso <@1@#stereo.ttl> .
'''.format(plugin_uri, plugin_name, plugin_stereo_uri)
endforeach

manifest_conf = configuration_data()
manifest_conf.set('LIB_EXT', extension)
manifest_conf.set('MANIFEST_CONTENT', manifest_content)

configure_file(
    input: 'lv2ttl/manifest.ttl.in',
    output: 'manifest.ttl',
    configuration: manifest_conf,
    install: true,
	install_dir: install_folder
)

