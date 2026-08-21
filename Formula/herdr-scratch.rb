class HerdrScratch < Formula
  desc "Scratch shell popup for herdr that detaches instead of closing"
  homepage "https://github.com/macintacos/herdr-scratch"
  url "https://github.com/macintacos/herdr-scratch/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "983849bfce859808b7a1e697d920a03d5b19ec666496a5214887a1cb99f840c6"
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
      Register the plugin with herdr. Once — upgrades need nothing:

        herdr-scratch link

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
