# /bin/bash

MIX_ENV=prod DATABASE_URL=$1 mix do ecto.migrate, import_data $2