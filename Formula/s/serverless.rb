require "language/node"

class Serverless < Formula
  desc "Build applications with serverless architectures"
  homepage "https://www.serverless.com/"
  url "https://github.com/serverless/serverless/archive/refs/tags/v3.36.0.tar.gz"
  sha256 "43b0c61fb3533c539813e712ba6925886613ef647e1950c4d725874d1e6d8dc1"
  license "MIT"
  head "https://github.com/serverless/serverless.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "4aa13af3dd6e2961ff50a48de52c9b8c340eb9aa064cb04e335e63becf69250f"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "4aa13af3dd6e2961ff50a48de52c9b8c340eb9aa064cb04e335e63becf69250f"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "4aa13af3dd6e2961ff50a48de52c9b8c340eb9aa064cb04e335e63becf69250f"
    sha256 cellar: :any_skip_relocation, sonoma:         "62d9fec648cff9b177b0e976e9fdcc3729d7a2c911a562df778b8010d7a4a760"
    sha256 cellar: :any_skip_relocation, ventura:        "62d9fec648cff9b177b0e976e9fdcc3729d7a2c911a562df778b8010d7a4a760"
    sha256 cellar: :any_skip_relocation, monterey:       "62d9fec648cff9b177b0e976e9fdcc3729d7a2c911a562df778b8010d7a4a760"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "0c1cb5025d0ab98643449a67a0517e8f8eeda9cd8b9cfe7851c973fe7085cfa2"
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir[libexec/"bin/*"]

    # Delete incompatible Linux CPython shared library included in dependency package.
    # Raise an error if no longer found so that the unused logic can be removed.
    (libexec/"lib/node_modules/serverless/node_modules/@serverless/dashboard-plugin")
      .glob("sdk-py/serverless_sdk/vendor/wrapt/_wrappers.cpython-*-linux-gnu.so")
      .map(&:unlink)
      .empty? && raise("Unable to find wrapt shared library to delete.")

    # Replace universal binaries with their native slices
    deuniversalize_machos libexec/"lib/node_modules/serverless/node_modules/fsevents/fsevents.node"
  end

  test do
    (testpath/"serverless.yml").write <<~EOS
      service: homebrew-test
      provider:
        name: aws
        runtime: python3.6
        stage: dev
        region: eu-west-1
    EOS

    system("#{bin}/serverless", "config", "credentials", "--provider", "aws", "--key", "aa", "--secret", "xx")
    output = shell_output("#{bin}/serverless package 2>&1")
    assert_match "Packaging homebrew-test for stage dev", output
  end
end
