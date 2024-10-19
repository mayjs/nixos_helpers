{pkgs, ...}:
pkgs.buildGoModule {
  name = "prometheus_remote_storage_adapter";
  src =
    pkgs.fetchFromGitHub {
      owner = "prometheus";
      repo = "prometheus";
      rev = "v2.54.1";
      hash = "sha256-SF9A/xyjQwwIcMZtuLeJiwkBZvvEyU5EKu0WXTQAT/A=";
    }
    + "/documentation/examples/remote_storage/";
  vendorHash = "sha256-lMBRc2/G8qTccADQm2LAEhCT/9ErESlf2g6+w87HlCg=";
  postInstall = ''
    mv $out/bin/remote_storage_adapter $out/bin/prometheus_remote_storage_adapter
  '';
}
