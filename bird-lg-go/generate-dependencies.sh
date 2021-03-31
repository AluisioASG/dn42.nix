#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nodePackages.node2nix
#
# SPDX-FileCopyrightText: 2019 Christian Kampka
# SPDX-FileCopyrightText: 2021 Aluísio Augusto Silva Gonçalves <https://aasg.name>
# SPDX-License-Identifier: MIT

node2nix \
  --nodejs-12 \
  --input node-packages.json \
  --node-env node-env.nix \
  --output node-packages.nix \
  --composition node-composition.nix
