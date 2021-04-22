# Skip comment lines.
/^;/ { next; }

# Store nameserver and glue records for later.
$3 == "NS" {
	nservers[$1 "."][$4] = "";
}
$3 == "A" || $3 == "AAAA" {
	glue[$1 "."][$4] = "";
}

# Mark zones with DNSSEC keys so we don't mark them with
# `domain-insecure` later.
$3 == "DS" || $3 == "DNSSEC" {
	dnssec[$1 "."] = "";
}

END {
	for (zone in nservers) {
		printf "server:\n  private-domain: %1$s\n  local-zone: %1$s nodefault\n", zone;
    if (! (zone in dnssec)) {
      printf "  domain-insecure: %s\n", zone;
    }

		printf "stub-zone:\n  name: %s\n", zone;
		for (ns in nservers[zone]) {
			# Use stub-addr if glue records are available.  Don't set
			# stub-host in that case as Unbound tries to resolve them
			# and ignores the glue.
			if (ns in glue) {
				for (g in glue[ns]) {
					printf "  stub-addr: %s@53#%s\n", g, ns;
				}
			} else {
				printf "  stub-host: %s\n", ns;
			}
		}
	}
}
