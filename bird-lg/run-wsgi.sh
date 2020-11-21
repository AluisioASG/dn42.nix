#!@shell@
PATH=@WRAPPER_PATH@
PYTHONPATH=@WRAPPER_PYTHONPATH@
export PATH PYTHONPATH
exec python -m gunicorn.app.wsgiapp @SCRIPT@ "$@"
