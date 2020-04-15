require "formula"

class RiscvGnuToolchain < Formula
  homepage "http://riscv.org"
  # url "https://github.com/riscv/riscv-gnu-toolchain.git"
  url "https://github.com/riscv/riscv-gnu-toolchain.git", :branch => "rvv-0.7.1"
  version "rvv-0.7.1"

  # bottle do
  # root_url 'http://riscv.org.s3.amazonaws.com/bottles'
  # sha256 "ce75cd6eb4220af90ed0587237f167be667fe1cf00b9a1ea02a652a66c33ff32" => :catalina
  # end

  option "with-multilib", "Build with multilib support"

  depends_on "gawk" => :build
  depends_on "gnu-sed" => :build
  depends_on "gmp"
  depends_on "mpfr"
  depends_on "libmpc"
  depends_on "isl"

  def install
    # disable crazy flag additions
    ENV.delete 'CPATH'

    # The build defaults to targetting RV64GC (64-bit)
    # Supported architectures are
    #   rv32i or rv64i plus standard extensions
    #   (a)tomics, (m)ultiplication and division, (f)loat, (d)ouble, or
    #   (g)eneral for MAFD.
    #   C = 16-bit Compressed Instructions ?
    # Supported ABIs are
    #   ilp32 (32-bit soft-float),
    #   ilp32d (32-bit hard-float),
    #   ilp32f (32-bit with single-precision in registers and double in memory, niche use only),
    #   lp64 lp64f lp64d (same but with 64-bit long and pointers).
    args = [
      # "--prefix=#{prefix}"
      "--prefix=#{prefix}",
      "--with-arch=rv32imafc",  # skip (d)
      "--with-abi=ilp32d",
      "--enable-multilib"
    ]
    args << "--enable-multilib" if build.with?("multilib")

    system "./configure", *args
    system "make"

    # don't install Python bindings if system already has them
    if File.exist?("#{HOMEBREW_PREFIX}/share/gcc-9.2.0")
      opoo "Not overwriting share/gcc-9.2.0"
      rm_rf "#{prefix}/share/gcc-9.2.0"
    end

    # don't install gdb bindings if system already has them
    if File.exist?("#{HOMEBREW_PREFIX}/share/gdb")
      opoo "Not overwriting share/gdb"
      rm_rf "#{prefix}/share/gdb"
      rm "#{prefix}/share/info/annotate.info"
      rm "#{prefix}/share/info/gdb.info"
      rm "#{prefix}/share/info/stabs.info"
    end

    # don't install gdb includes if system already has them
    if File.exist?("#{HOMEBREW_PREFIX}/include/gdb")
      opoo "Not overwriting include/gdb"
      rm_rf "#{prefix}/include/gdb"
    end
  end

  test do
    system "false"
  end
end
