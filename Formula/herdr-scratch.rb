class HerdrScratch < Formula
  desc "Scratch shell popup for herdr that detaches instead of closing"
  homepage "https://github.com/macintacos/herdr-scratch"
  url "https://github.com/macintacos/herdr-scratch/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "82928e424b2d0f00179ee9a881fbd05b76d4d643005fce841cf9b4127cb4d02f"
  license "MIT"
  head "https://github.com/macintacos/herdr-scratch.git", branch: "trunk"

  depends_on "go" => :build
  depends_on "herdr"
  # Not optional. tmux is what keeps the shell alive and the screen intact
  # between one press of the chord and the next.
  depends_on "tmux"

  def install
    # The formula prefix doubles as the plugin root herdr is pointed at, so the
    # path users have to type is one `brew --prefix` and nothing more. The
    # layout it needs is the repo's own: bin/herdr-scratch, beside the manifest,
    # tmux.conf and shell/ that the binary resolves relative to the root.
    system "go", "build", *std_go_args(output: bin/"herdr-scratch")
    prefix.install "herdr-plugin.toml", "tmux.conf", "shell"
  end

  def caveats
    <<~EOS
      herdr has no plugin search path, and a formula must not write outside
      Homebrew's prefix, so registering the plugin is yours to run:

        herdr plugin link #{opt_prefix}

      Run it again after upgrading this formula. herdr resolves that path down
      to the real directory, which is version-numbered, so an upgrade leaves
      the registration pointing at a version that no longer exists.

      Then bind a key in ~/.config/herdr/config.toml:

        [[keys.command]]
        key         = "prefix+'"
        type        = "plugin_action"
        command     = "user.scratch.toggle"
        description = "scratch shell"

      and apply it with:

        herdr server reload-config
    EOS
  end

  test do
    assert_match "herdr-scratch", shell_output("#{bin}/herdr-scratch --help")

    # The plugin root has to carry more than the binary, or herdr loads a
    # plugin whose pane command and shell integration are both missing.
    assert_path_exists prefix/"herdr-plugin.toml"
    assert_path_exists prefix/"tmux.conf"
    assert_path_exists prefix/"shell/herdr-scratch.fish"
  end
end
