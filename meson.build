project('nrepellent.lv2','c',version: '0.2.3',default_options: ['default_library=shared','c_std=c99'])

# Install folder
lv2_directory = join_paths(get_option('libdir'), 'lv2')
install_folder = join_paths(lv2_directory, meson.project_name())

# Common sources for all plugins
common_src = ['src/signal_crossfade.c']
noise_profile_src = ['src/noise_profile_state.c']

# Plugin source lists
noise_repellent_src = ['plugins/nrepellent.c'] + noise_profile_src
noise_repellent_ex_src = ['plugins/nrepellentEx.c'] + noise_profile_src
noise_repellent_adaptive_src = 'plugins/nrepellent-adaptive.c'
nrepellent_fs1_src = ['plugins/nrepellent_fs1.c'] + noise_profile_src
nrepellent_fs4_src = ['plugins/nrepellent_fs4.c'] + noise_profile_src
nrepellent_fs16_src = ['plugins/nrepellent_fs16.c'] + noise_profile_src

# libspecbleach sources
libspecbleach_sources = [
    'subprojects/libspecbleach/src/shared/utils/spectral_utils.c',
    'subprojects/libspecbleach/src/shared/utils/spectral_features.c',
    'subprojects/libspecbleach/src/shared/utils/general_utils.c',
    'subprojects/libspecbleach/src/shared/utils/denoise_mixer.c',
    'subprojects/libspecbleach/src/shared/post_estimation/spectral_whitening.c',
    'subprojects/libspecbleach/src/shared/post_estimation/postfilter.c',
    'subprojects/libspecbleach/src/shared/pre_estimation/noise_scaling_criterias.c',
    'subprojects/libspecbleach/src/shared/pre_estimation/critical_bands.c',
    'subprojects/libspecbleach/src/shared/pre_estimation/absolute_hearing_thresholds.c',
    'subprojects/libspecbleach/src/shared/pre_estimation/masking_estimator.c',
    'subprojects/libspecbleach/src/shared/pre_estimation/transient_detector.c',
    'subprojects/libspecbleach/src/shared/pre_estimation/spectral_smoother.c',
    'subprojects/libspecbleach/src/shared/gain_estimation/gain_estimators.c',
    'subprojects/libspecbleach/src/shared/noise_estimation/adaptive_noise_estimator.c',
    'subprojects/libspecbleach/src/shared/noise_estimation/noise_estimator.c',
    'subprojects/libspecbleach/src/shared/noise_estimation/noise_profile.c',
    'subprojects/libspecbleach/src/shared/stft/fft_transform.c',
    'subprojects/libspecbleach/src/shared/stft/stft_windows.c',
    'subprojects/libspecbleach/src/shared/stft/stft_buffer.c',
    'subprojects/libspecbleach/src/shared/stft/stft_processor.c',
    'subprojects/libspecbleach/src/denoiser/spectral_denoiser.c',
    'subprojects/libspecbleach/src/adaptivedenoiser/adaptive_denoiser.c',
    'subprojects/libspecbleach/src/specbleach_adenoiser.c',
    'subprojects/libspecbleach/src/specbleach_denoiser.c',
]
libspecbleach_inc = include_directories('subprojects/libspecbleach/include')

# Base dependencies
lv2_dep = dependency('lv2', required: true)
m_dep = meson.get_compiler('c').find_library('m', required: true)
fftw_dep = dependency('fftw3f', required : true)
libspecbleach_base_deps = [fftw_dep, m_dep]

# Get the host operating system and cpu architecture
current_os = host_machine.system()
current_arch = build_machine.cpu_family()

# Shared c_args for libraries
lib_c_args = ['-fvisibility=hidden']
if current_arch == 'x86' or current_arch == 'x86_64' and current_os != 'darwin'
    lib_c_args += ['-msse','-msse2','-mfpmath=sse','-ffast-math','-fomit-frame-pointer','-fno-finite-math-only']
endif

# --- Build default libspecbleach and original plugins ---
lib_spec_default = static_library('specbleach_default',
    libspecbleach_sources,
    c_args: lib_c_args,
    include_directories: libspecbleach_inc,
    dependencies: libspecbleach_base_deps
)
dep_spec_default = declare_dependency(include_directories: libspecbleach_inc, link_with: lib_spec_default)
default_plugin_deps = [lv2_dep, m_dep, dep_spec_default]

library('nrepellent', common_src, noise_repellent_src, c_args: lib_c_args, name_prefix: '', dependencies: default_plugin_deps, install: true, install_dir: install_folder)
library('nrepellentEx', common_src, noise_repellent_ex_src, c_args: lib_c_args, name_prefix: '', dependencies: default_plugin_deps, install: true, install_dir: install_folder)
library('nrepellent-adaptive', common_src, noise_repellent_adaptive_src, c_args: lib_c_args, name_prefix: '', dependencies: default_plugin_deps, install: true, install_dir: install_folder)

# --- Build Frame Size variant plugins ---
foreach size : ['1', '4', '16']
  fs_c_args = lib_c_args + ['-DFRAME_SIZE_GENERAL=' + size]
  lib_spec_variant = static_library('specbleach_fs' + size,
    libspecbleach_sources,
    c_args: fs_c_args,
    include_directories: libspecbleach_inc,
    dependencies: libspecbleach_base_deps
  )
  dep_spec_variant = declare_dependency(include_directories: libspecbleach_inc, link_with: lib_spec_variant)

  plugin_name = 'nrepellent_fs' + size
  plugin_srcs = get_variable('nrepellent_fs' + size + '_src')
  plugin_deps = [lv2_dep, m_dep, dep_spec_variant]

  library(plugin_name,
    common_src,
    plugin_srcs,
    c_args: lib_c_args,
    name_prefix: '',
    dependencies: plugin_deps,
    install: true,
    install_dir: install_folder
  )
endforeach

# --- Configure TTL files ---
if current_os == 'darwin'
    extension = '.dylib'
else
    extension = '.so'
endif
if current_os == 'windows'
    extension = '.dll'
endif

manifest_conf = configuration_data()
manifest_conf.set('LIB_EXT', extension)
configure_file(
    input: 'lv2ttl/manifest.ttl.in',
    output: 'manifest.ttl',
    configuration: manifest_conf,
    install: true,
	install_dir: install_folder
)

version_array = meson.project_version().split('.')
git = find_program('git', native: true, required: false)
if version_array.length() == 0 and git.found()
    version_array = run_command('git', 'describe').stdout().strip().split('-')[0].split('.')
endif
data_conf = configuration_data()
data_conf.set('MAJOR_VERSION', version_array[0])
data_conf.set('MINOR_VERSION', version_array[1])
data_conf.set('MICRO_VERSION', version_array[2])

ttl_files = [
  'nrepellent', 'nrepellent#stereo',
  'nrepellent-adaptive', 'nrepellent-adaptive#stereo',
  'nrepellentEx', 'nrepellentEx#stereo',
  'nrepellent_fs1', 'nrepellent_fs1#stereo',
  'nrepellent_fs4', 'nrepellent_fs4#stereo',
  'nrepellent_fs16', 'nrepellent_fs16#stereo'
]

foreach f : ttl_files
  configure_file(
      input: join_paths('lv2ttl', f + '.ttl.in'),
      output: f + '.ttl',
      configuration: data_conf,
      install: true,
      install_dir: install_folder
  )
endforeach
