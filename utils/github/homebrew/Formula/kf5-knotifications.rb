class Kf5Knotifications < Formula
  desc "Abstraction for system notifications"
  homepage "https://www.kde.org"
  url "https://download.kde.org/stable/frameworks/5.94/knotifications-5.94.0.tar.xz"
  sha256 "c8d51ce32b65f096c75da3e7bdb033202086cabaa8faad3bcdd46730b74b43bf"
  head "https://invent.kde.org/frameworks/knotifications.git"

  depends_on "cmake" => [:build, :test]
  depends_on "ninja" => :build

  depends_on "copyq/kde/extra-cmake-modules" => [:build, :test]
  depends_on "copyq/kde/kf5-kconfig"
  depends_on "copyq/kde/kf5-kcoreaddons"
  depends_on "copyq/kde/kf5-kwindowsystem"
  depends_on "libcanberra"

  def install
    args = std_cmake_args

    args << "-DQT_MAJOR_VERSION=6"
    args << "-DEXCLUDE_DEPRECATED_BEFORE_AND_AT=5.90.0"

    args << "-DBUILD_TESTING=OFF"
    args << "-DBUILD_QCH=OFF"
    args << "-DKDE_INSTALL_QMLDIR=lib/qt6/qml"
    args << "-DKDE_INSTALL_PLUGINDIR=lib/qt6/plugins"
    args << "-DKDE_INSTALL_QTPLUGINDIR=lib/qt6/plugins"

    inreplace "CMakeLists.txt",
              "find_package(Qt5MacExtras ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE)",
              ""
    inreplace "KF5NotificationsConfig.cmake.in",
              "find_dependency(Qt5MacExtras @REQUIRED_QT_VERSION@)",
              ""
    inreplace "src/CMakeLists.txt",
              'target_link_libraries(KF5Notifications PRIVATE Qt5::MacExtras "-framework Foundation" "-framework AppKit")',
              ""

    mkdir "build" do
      system "cmake", "-G", "Ninja", "..", *args
      system "ninja"
      system "ninja", "install"
      prefix.install "install_manifest.txt"
    end
  end

  test do
    (testpath/"CMakeLists.txt").write("find_package(KF5Notifications REQUIRED)")
    system "cmake", ".", "-Wno-dev"
  end
end
