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
    gef # GDB extension
    one_gadget # libc RCE gadget finder
    pwninit # runs executables for binexp
    pwntools # Python library for binexp, includes checksec
    ltrace # library call tracer
    strace # syscall tracer
  ];

  # TODO: 32-bit binary support
}
