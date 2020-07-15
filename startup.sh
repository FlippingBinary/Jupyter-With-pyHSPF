#!/bin/bash

set -e

JUPYTER_PASSWORD=${JUPYTER_PASSWORD:-jupyter}
PORT=${PORT:-8888}

mkdir -p ~/.jupyter

PASSWORD_HASH=`/opt/conda/bin/python -c "from notebook.auth import passwd;print(passwd('$JUPYTER_PASSWORD'))"`

cat > ~/.jupyter/jupyter_notebook_config.json <<EOF
{
  "NotebookApp": {
    "password": "$PASSWORD_HASH"
  }
}
EOF

cat <<EOF
  Created hash: $PASSWORD_HASH
  From password: $JUPYTER_PASSWORD
EOF

chmod 0600 ~/.jupyter/jupyter_notebook_config.json


exec /opt/conda/bin/jupyter lab --notebook-dir=/opt/notebooks --ip='*' --port=$PORT --no-browser
