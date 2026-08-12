# Reforge Robotics APT Repository

This repository publishes Reforge Robotics Debian packages for
supported Ubuntu machines.

## Supported Platforms

```text
Repository setup: Ubuntu 20.04 focal, 22.04 jammy, 24.04 noble; amd64 or arm64
Joint Tracker C++ SDK: Ubuntu 20.04 or newer; amd64 or arm64
Shaper C++ SDK: Ubuntu 20.04 or newer; amd64
reforge-core bundle: Ubuntu 20.04 or newer; amd64
```

The setup script exits with an error on unsupported operating systems
before it writes an APT source. Individual package dependencies then
enforce component-specific platform support.

On arm64, install `reforge-core-joint-tracker` directly. The Shaper
package and `reforge-core` bundle remain amd64-only until their arm64
release paths are separately validated.

## Install Reforge Core C++ SDK Packages

Install the basic tools needed to add the repository:

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg
```

Add the signed Reforge APT repository:

```bash
curl -fsSL https://reforge-robotics.github.io/reforge-core-cpp/setup.sh | sudo bash
```

Install only the Shaper C++ SDK package:

```bash
sudo apt update
sudo apt install -y reforge-core-shaper
```

Install only the Joint Tracker C++ SDK package:

```bash
sudo apt update
sudo apt install -y reforge-core-joint-tracker
```

Or install the default Reforge Core package set:

```bash
sudo apt update
sudo apt install -y reforge-core
```

## Validate The Installed SDK

Check installed package versions:

```bash
dpkg-query -W -f='${Package} ${Version} ${Architecture}\n' reforge-core-shaper
dpkg-query -W -f='${Package} ${Version} ${Architecture}\n' reforge-core-joint-tracker
```

Build and run the Shaper demo shipped with the SDK:

```bash
sudo apt install -y cmake build-essential
cmake -S /usr/share/reforge-core-shaper/examples -B /tmp/reforge-shaper-demo
cmake --build /tmp/reforge-shaper-demo --parallel
/tmp/reforge-shaper-demo/reforge_shaper_demo
```

Expected demo output:

```text
Reforge Shaper C++ demo complete.
```

Build and run the complete Shaper backend demo:

```bash
cmake -S /usr/share/reforge-core-shaper/examples/backend -B /tmp/reforge-shaper-backend-demo
cmake --build /tmp/reforge-shaper-backend-demo --parallel
/tmp/reforge-shaper-backend-demo/reforge_shaper_backend_demo
```

Expected demo output:

```text
Reforge Shaper backend demo complete.
```

Build and run the Joint Tracker demo shipped with the SDK:

```bash
sudo apt install -y cmake build-essential
cmake -S /usr/share/reforge-core-joint-tracker/examples -B /tmp/reforge-joint-tracker-demo
cmake --build /tmp/reforge-joint-tracker-demo --parallel
/tmp/reforge-joint-tracker-demo/reforge_joint_tracker_driver_loop_demo
```

Expected demo output:

```text
Reforge Joint Tracker driver loop complete.
```

## Use The SDK In Your CMake Project

After installation, use the exported CMake package:

```cmake
cmake_minimum_required(VERSION 3.22)
project(reforge_shaper_app LANGUAGES CXX)

find_package(ReforgeShaper CONFIG REQUIRED)

add_executable(reforge_shaper_app main.cpp)
target_link_libraries(reforge_shaper_app PRIVATE ReforgeShaper::runtime)
```

For complete Shaper backend applications, link the backend target:

```cmake
find_package(ReforgeShaper CONFIG REQUIRED)
target_link_libraries(reforge_shaper_app PRIVATE ReforgeShaper::backend)
```

For Joint Tracker:

```cmake
cmake_minimum_required(VERSION 3.16)
project(reforge_joint_tracker_app LANGUAGES CXX)

find_package(ReforgeJointTracker CONFIG REQUIRED)

add_executable(reforge_joint_tracker_app main.cpp)
target_link_libraries(
    reforge_joint_tracker_app
    PRIVATE ReforgeJointTracker::joint_tracker
)
```

The package installs SDK files under:

```text
/usr/include/reforge_core
/usr/lib/x86_64-linux-gnu
/usr/lib/x86_64-linux-gnu/cmake/ReforgeShaper
/usr/lib/x86_64-linux-gnu/cmake/ReforgeJointTracker
/usr/share/reforge-core-shaper/examples
/usr/share/reforge-core-joint-tracker/examples
```

## Upgrade

Upgrade the Shaper C++ SDK:

```bash
sudo apt update
sudo apt install -y reforge-core-shaper
```

Upgrade the Joint Tracker C++ SDK:

```bash
sudo apt update
sudo apt install -y reforge-core-joint-tracker
```

Upgrade the default Reforge Core package set:

```bash
sudo apt update
sudo apt install -y reforge-core
```

`apt install` is intentional for named Reforge packages: it upgrades
an installed package to the repository candidate and resolves exact
component dependencies for meta packages. Do not use
`apt upgrade <package>` for the Reforge meta package.

Run the installed demo again after upgrading to confirm the SDK
still builds and links correctly.

## Repository Contents

This repository is generated release output. The source code,
packaging scripts, and release workflow live in the private
`reforge-robotics/reforge-core` repository.
