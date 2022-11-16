# This configuration for laptop lids actions

{ config, lib, pkgs, ... }:

{
  # TODO(breakds): Add a detailed configuration for key remapping
  # using udev, following
  # https://discourse.nixos.org/t/configuring-caps-lock-as-control-on-console/9356
  config = {
    # Handle lids for laptops.
    services.logind = {
      # The following settings configures the following behavior for laptops
      # When the lid close event is detected,
      #   1. If the external power is on, do nothing
      #   2. If the laptop is docked (external dock or monitor or hub), do nothing
      #   3. Otherwise, it should go to suspend and then hibernate. However this action
      #      will be held off for 60 seconds to wait for the users to dock or plug
      #      external power.
      lidSwitch = "suspend-then-hibernate";
      lidSwitchDocked = "ignore";
      lidSwitchExternalPower = "ignore";
      extraConfig = ''
        HoldoffTimeoutSec=60
      '';
    };

    # Suspend-to-RAM. This state, if supported, offers significant power savings
    # as everything in the system is put into a low-power state, except for
    # memory, which should be placed into the self-refresh mode to retain its
    # contents.
    boot.kernelParams = [ "mem_sleep_default=deep" ];

    # This follows olmokramer's solution from this post:
    # https://discourse.nixos.org/t/configuring-caps-lock-as-control-on-console/9356/2
    services.udev.extraHwdb = ''
      evdev:input:b0011v0001p0001eAB54*
        KEYBOARD_KEY_3A=leftctrl    # CAPSLOCK -> CTRL
    '';
  };
}
