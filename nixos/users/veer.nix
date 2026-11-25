{ ... }:

{
  users.users.veer = {
    isNormalUser = true;
    description = "veer";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK6adLMF294/a1BjOUP35x7S/5i7W7Ez+bKCAnNPMcQn cowboyhehe1@gmail.com"
    ];
  };
}
