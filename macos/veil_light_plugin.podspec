#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint veil_light_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'veil_light_plugin'
  s.version          = '0.0.1'
  s.summary          = 'Veil light wallet plugin'
  s.description      = <<-DESC
  Veil light wallet plugin.
                       DESC
  s.homepage         = 'https://veil-project.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Ivan Yv' => 'ivan.yurkov@steel-team.net' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'

  s.script_phase = {
    :name => 'Build Rust library',
    # First argument is relative path to the `rust` folder, second is name of rust library
    :script => 'sh "$PODS_TARGET_SRCROOT/../cargokit/build_pod.sh" ../rust hello_rust_ffi_plugin',
    :execution_position => :before_compile,
    :input_files => ['${BUILT_PRODUCTS_DIR}/cargokit_phony'],
    # Let XCode know that the static library referenced in -force_load below is
    # created by this build step.
    :output_files => ["${BUILT_PRODUCTS_DIR}/libhello_rust_ffi_plugin.a"],
  }
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    # Flutter.framework does not contain a i386 slice.
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'OTHER_LDFLAGS' => '-force_load ${BUILT_PRODUCTS_DIR}/libhello_rust_ffi_plugin.a',
  }
end
