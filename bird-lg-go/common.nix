# SPDX-FileCopyrightText: 2021 Aluísio Augusto Silva Gonçalves <https://aasg.name>
# SPDX-License-Identifier: MIT

{ lib, fetchFromGitHub }: {
  version = "2021-03-31-unstable";

  src = fetchFromGitHub {
    owner = "xddxdd";
    repo = "bird-lg-go";
    rev = "5b5a09ccbddc2b35e080a9df0237ce6cc97a25a3";
    hash = "sha256-5lfOmbS3A+EwAINGQwqTLvhnh+kcpN5qKTQj4yCyNsM=";
  };

  meta = with lib; {
    description = "Looking glass for the BIRD Internet Routing Daemon";
    homepage = "https://github.com/xddxdd/bird-lg-go";
    license = licenses.gpl3Only;
    platforms = platforms.unix;
    maintainers = with maintainers; [ AluisioASG ];
  };
}
