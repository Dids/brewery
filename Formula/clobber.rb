class Clobber < Formula
  desc "Command-line application for building Clover"
  homepage "https://github.com/Dids/clobber"
  url "https://github.com/Dids/clobber/archive/v0.2.4.tar.gz"
  sha256 "1854a2abb9941591634214de117d0025b7e2d0aecd6a3659a4d0c9f3ec8e2d67"
  revision 0

  # Setup HEAD support (install with --HEAD)
  head "https://github.com/Dids/Clobber.git", :branch => "master"

  # No bottling necessary
  bottle :unneeded

  # We need dep for build dependencies
  depends_on "dep" => :build

  # We need go for building
  depends_on "go" => :build

  # We needs subversion for SVN support
  depends_on "subversion"
  
  # We need Xcode/xcodebuild for running the application
  depends_on :xcode

  # We need gettext for bulding EDK/Clover
  depends_on "gettext"

  # Define the installation steps
  def install
    # Define GOPATH
    ENV["GOPATH"] = buildpath/"go"
    ENV["GOBIN"] = buildpath/"go/bin"

    # Create the required directory structure
    (buildpath/"go/bin").mkpath
    (buildpath/"go/pkg").mkpath
    (buildpath/"go/src").mkpath
    (buildpath/"go/src/github.com/Dids/clobber").mkpath

    # Copy everything to the Go project directory (except the go/ folder)
    system "rsync -a ./ go/src/github.com/Dids/clobber/"

    # Switch to the Go project directory
    Dir.chdir 'go/src/github.com/Dids/clobber' do
      ohai "Switched to directory: #{Dir.pwd}"

      # Print out target version
      ohai "Building version #{version}.."

      # Build the application
      system "make", "deps"
      system "make", "build", "BINARY_VERSION=#{version}", "BINARY_OUTPUT=#{buildpath}/clobber"
      system "make", "test"

      # Print the version
      system buildpath/"clobber", "--version"

      # Install the application
      bin.install buildpath/"clobber"

      # Test that the version matches
      if "clobber version #{version}" != `#{bin}/clobber --version`.strip
        odie "Output of 'clobber --version' did not match the current version (#{version})."
      end
    end
  end

  test do
    # Test that the version matches
    assert_equal "clobber version #{version}", `#{bin}/clobber --version`.strip
  end
end
