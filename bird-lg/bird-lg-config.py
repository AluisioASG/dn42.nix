# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
# SPDX-License-Identifier: MIT

# Put everything inside a function to avoid polluting the script's
# global namespace.
def _config_loader_main():
    """ Loads bird-lg and gunicorn config files. """
    import os

    def log_to_syslog():
        """ Configures the logging module to log everything to syslog. """
        from logging.config import dictConfig
        import socket

        dictConfig(
            {
                "version": 1,
                "formatters": {"msgonly": {"format": "%(message)s"}},
                "handlers": {
                    "syslog": {
                        "class": "logging.handlers.SysLogHandler",
                        "formatter": "msgonly",
                        "address": "/dev/log",
                        "socktype": socket.SOCK_DGRAM,
                    }
                },
                "root": {"handlers": ["syslog"]},
            }
        )

    def load_config_files():
        """ Loads JSON config files specified in the BIRD_LG_CONFIG_FILES environment variable. """
        import json

        for filename in os.environ["BIRD_LG_CONFIG_FILES"].split(os.pathsep):
            with open(filename, "r") as file:
                config = json.load(file)
                globals().update(config)

    if os.environ.get("BIRD_LG_SYSLOG"):
        log_to_syslog()
    if os.environ.get("BIRD_LG_CONFIG_FILES"):
        load_config_files()


_config_loader_main()
del _config_loader_main
