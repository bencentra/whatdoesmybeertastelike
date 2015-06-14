# Dependencies #

In addition to the pip dependencies, you also need:
```
redis-server
```

# Running It #
```
uwsgi --ini uwsgi.ini
celery -A server.celery beat
```

Celery isn't running as a daemon yet so will need to be run second
or in a separate shell.

# Killing Uwsgi #
```
kill -KILL $(cat /tmp/uwsgi.pid)
```
