# Building PDFium Native Code

## Instructions

1. **Copy `build_pdfium.sh` to a Linux-based virtual machine:**
    - Copy the script `build_pdfium.sh` (or its content) to your Linux VM.

2. **Edit `basedir` and grant execution permissions:**
    - Open the `build_pdfium.sh` file in a text editor.
    - Edit the `basedir` variable to specify the desired directory where you want the PDFium project to be cloned.
    - Grant execute permissions to the script using the command:
      ```bash
      chmod +x build_pdfium.sh
      ```

3. **Run the script:**
    - Execute the script and wait for it to finish. This will clone the latest stable branch of the PDFium repository into the specified directory along with all required dependencies and third-party libraries.
      ```bash
      ./build_pdfium.sh
      ```

4. **Edit `BUILD.gn` in the cloned PDFium repository:**
    - Navigate to the newly cloned `pdfium` repository.
    - Open the `BUILD.gn` file in a text editor.
    - In the `config("pdfium_common_config")` section, update the `cflags`, `ldflags`, and `defines` as follows:
      ```gn
      cflags = [
          "-fvisibility=default",
          "-Oz",  # This reduces the size of the final binary
      ]
      ldflags = [
          "-Wl,-export-dynamic",      # Export dynamic symbols
          "-Wl,-z,max-page-size=16384",  # Set max page size
      ]
      include_dirs = [ "." ]
      defines = ["FPDFSDK_EXPORTS"]
      ```
    - Add a new `shared_library` entry:
      ```gn
      shared_library("modpdfium") {
        deps = [":pdfium", "//buildtools/third_party/libunwind"]
        if (target_os == "android") {
          configs -= [ "//build/config/android:hide_all_but_jni_onload" ]
        }
      }
      ```
    - Save and exit the file.

5. **Edit `BUILD.gn` in `buildtools/third_party/libunwind`:**
    - Navigate to the `../pdfium/buildtools/third_party/libunwind` directory.
    - Open the `BUILD.gn` file in a text editor.
    - Search for the `source_set("libunwind")` section and update the `visibility` modifier for Android builds:
      ```gn
      visibility = [ "//buildtools/third_party/libc++abi" ]
      if (is_android) {
        visibility += [ "//services/tracing/public/cpp", "//:modpdfium" ]
      }
      ```
    - Save and exit the file.

6. **Copy `build.sh` to the PDFium repository:**
    - Copy the `build.sh` script (or its content) from your project into the `../pdfium/` repository folder.
    - Grant execute permissions to the script using the command:
      ```bash
      chmod +x build.sh
      ```

7. **Run the build script:**
    - Execute the `build.sh` script to generate PDFium artifacts for `arm`, `arm64`, `x86`, and `x64` build targets.
    - The default `--args` list is optimized for building pdfium for android without using `v8`, `xfa` and `skia`
      ```bash
      ./build.sh
      ```

8. **Locate the generated files:**
    - After execution, a zip file containing all required `.so` files for different architectures and all public `*.h` files will be created in the `../pdfium/libmodpdfium/` folder.