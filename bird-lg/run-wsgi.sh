#!@shell@
# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
# SPDX-License-Identifier: MIT

PATH=@WRAPPER_PATH@
PYTHONPATH=@WRAPPER_PYTHONPATH@
export PATH PYTHONPATH
exec python -m gunicorn.app.wsgiapp @SCRIPT@ "$@"
