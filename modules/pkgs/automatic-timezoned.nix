{ lib
, fetchFromGitHub
, rustPlatform
}:

rustPlatform.buildRustPackage rec {
  pname = "automatic-timezoned";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "maxbrunet";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-oSJcPVd1BqWw3WlKAGq909KlSJU7ZMDsQMXjwEjRPWI=";
  };

  cargoSha256 = "sha256-qdywPUzvUq8Cw19EReQCFUErVgPxLxC9k7M0ayUu1kE=";

  meta = with lib; {
    description = "Automatically update system timezone based on location";
    homepage = "https://github.com/maxbrunet/automatic-timezoned";
    license = licenses.gpl3;
    maintainers = [ ];
  };
}

