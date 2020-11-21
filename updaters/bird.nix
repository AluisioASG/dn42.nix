# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
# SPDX-License-Identifier: MIT

{
  dn42.updaters.bird1-roa4 = {
    source = "https://dn42.burble.com/roa/dn42_roa_bird1_4.conf";
    destination = "/etc/bird/roa_dn42_v4.conf";
    services = [ "bird.service" ];
    interval = "33min";
  };

  dn42.updaters.bird1-roa6 = {
    source = "https://dn42.burble.com/roa/dn42_roa_bird1_6.conf";
    destination = "/etc/bird/roa_dn42_v6.conf";
    services = [ "bird6.service" ];
    interval = "33min";
  };

  dn42.updaters.bird2-roa4 = {
    source = "https://dn42.burble.com/roa/dn42_roa_bird2_4.conf";
    destination = "/etc/bird/roa_dn42_v4.conf";
    services = [ "bird2.service" ];
    interval = "33min";
  };

  dn42.updaters.bird2-roa6 = {
    source = "https://dn42.burble.com/roa/dn42_roa_bird2_6.conf";
    destination = "/etc/bird/roa_dn42_v6.conf";
    services = [ "bird2.service" ];
    interval = "33min";
  };

  dn42.updaters.bird2-roa46 = {
    source = "https://dn42.burble.com/roa/dn42_roa_bird2_46.conf";
    destination = "/etc/bird/roa_dn42.conf";
    services = [ "bird2.service" ];
    interval = "33min";
  };
}
