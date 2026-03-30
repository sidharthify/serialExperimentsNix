{ pkgs, ... }:

{
users.users.arkserver = {
     isNormalUser = true;
     description = "ark server user";
     home = "/home/arkserver";
 };

security.pam.loginLimits = [
    { domain = "*"; type = "soft"; item = "nofile"; value = "1000000"; }
    { domain = "*"; type = "hard"; item = "nofile"; value = "1000000"; }
  ];
}
