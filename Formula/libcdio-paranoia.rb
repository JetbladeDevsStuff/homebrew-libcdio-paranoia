class LibcdioParanoia < Formula
  desc "CD paranoia CD-DA library from libcdio"
  homepage "https://www.gnu.org/software/libcdio/"
  version "10.2+2.0.1"
  license "GPL-3.0-or-later"

  stable do
    url "https://ftp.gnu.org/gnu/libcdio/libcdio-paranoia-10.2+2.0.1.tar.bz2"
    sha256 "33b1cf305ccfbfd03b43936975615000ce538b119989c4bec469577570b60e8a"

    # Fix -flat_namespace being used on Big Sur and later
    patch do
      url "https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-big_sur.diff"
      sha256 "35acd6aebc19843f1a2b3a63e880baceb0f5278ab1ace661e57a502d9d78c93c"
    end
  end

  livecheck do
    url "https://ftp.gnu.org/gnu/libcdio/"
    regex(%r{href=.*?libcdio-paranoia[._-](\d+(?:\.\d+\+?\d?)*)(?:\.[a-z]+|/)}i)
  end

  head do
    url "https://github.com/rocky/libcdio-paranoia.git", branch: "master"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "libcdio"

  def install
    system "autoreconf", "-fi" if build.head?
    # Versioned libraries only work on GNU ld
    system "./configure", *std_configure_args, "--disable-silent-rules",
                          "--without-versioned-libs"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <cdio/paranoia/paranoia.h>
      #include <cdio/paranoia/cdda.h>
      int main(void) {
        cdio_paranoia_version();
        cdio_cddap_version();
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lcdio_paranoia", "-lcdio_cdda",
      "-o", "test"
    system "./test"
    system "#{bin}/cd-paranoia", "--version"
  end
end
