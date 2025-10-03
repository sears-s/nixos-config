{
  config,
  lib,
  osConfig,
  pkgs,
  specialArgs,
  ...
}:
lib.mkIf specialArgs.security {

  # Programs not available as a home-manager program
  home.packages = with pkgs; [
    bintools # strings, etc.
    binwalk # extract files via header
    gef # GDB extension
    nmap # network scanner
    one_gadget # libc RCE gadget finder
    pwninit # runs executables for binexp
    pwntools # Python library for binexp, includes checksec
    ltrace # library call tracer
    sqlmap # SQL injection utility
    strace # syscall tracer
    volatility2-bin # memory analysis (old)
    volatility3 # memory analysis (new)
  ];

  # TODO: 32-bit binary support
}
