# Building PDFium Native Code

## Instructions

1. **Copy `build_pdfium.sh` to a Linux-based machine:**
    - Copy the script `build_pdfium.sh` (or its content) on a Linux based machine.

2. **Edit `basedir`, `githash` and grant execution permissions:**
    - Open the `build_pdfium.sh` file in a text editor.
    - (Optional) Edit the `basedir` variable to specify the desired directory where you want the PDFium project to be cloned.
    - (Optional) Edit the `githash` to the latest stable pdfium version 
    - Grant execute permissions to the script using the command:
      ```bash
      chmod +x build_pdfium.sh
      ```

3. **Run the script:**
    - Make sure no `depot_tools` are present in your `$PATH` variable if they are remove them
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
          "-Oz"  #This reduces the size of the final binary (use only for release builds) 
                  https://clang.llvm.org/docs/CommandGuide/clang.html#code-generation-options
      ]
      ldflags = [
          "-Wl,-export-dynamic"      # Export dynamic symbols
      ]
      include_dirs = [ "." ]
      defines = ["FPDFSDK_EXPORTS"]
      ```
    - (OPTIONAL) If you want to build pdfium as a shared lib  add a `shared_library` entry:
      ```gn
      shared_library("modpdfium") {
        deps = [":pdfium", "//buildtools/third_party/libunwind"]
        if (target_os == "android") {
          configs -= [ "//build/config/android:hide_all_but_jni_onload" ]
        }
      }
      ```
    - (OPTIONAL) If you want to build pdfium as static_lib add a `static_library` entry:
      ```gn
      shared_library("modpdfium") {
        deps = [":pdfium"]
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

6. **(Optional) Edit `BUILD.gn` and `config.gni` in `../build/config/android`:**
   - Navigate to the `../build/config/android` directory.
   - (Optional) Open the `BUILD.gn` file in a text editor to change the page size number for 16 KB page sizes
     - Search for the `_max_page_size` section and update the value to `16384` this will ensure tha:
   - (Optional) Change `default_android_ndk_version` in `config.gni`
   
7. **Build PDFium :**
    - Depending on what type of output you want either copy `build_shared_lib.sh` or `build_static_lib.sh` into the `../pdfium/` repository folder
    - Grant execute permissions to the script using the command:
      ```bash
      chmod +x build.sh
      ```

8. **Run the build script:**
    - Execute the above script to generate PDFium artifacts for `arm`, `arm64`, `x86`, and `x64` build targets.
    - The default `--args` list is optimized for building pdfium for android without using `v8`, `xfa` and `skia`
      ```bash
      ./build.sh
      ```

9. **Locate the generated files:**
    - After execution, a `libmodpdfium.zip` in the `../pdfium/libmodpdfium/` folder.
    - The zip contains the `.so`  or `.a` files for different architectures 
    - It also contains all `*.h` files from `public/*.h` in the pdfium repository