# Project Repository

This is the initial README file for the project.

## Database Schema

The full PostgreSQL schema is located at `calendar_database/schema.sql`.  
To initialize your local database, see the instructions at the top of that file.

## Local Database Setup

The calendar app schema uses PostgreSQL running on port 5000 by default.  
Connection/example credentials are stored in:

- `calendar_database/db_visualizer/postgres.env` (for app/scripts)
- `calendar_database/db_connection.txt` (quick CLI connect string)

Default values (change as needed):
- `POSTGRES_URL="postgresql://localhost:5000/myapp"`
- `POSTGRES_USER="appuser"`
- `POSTGRES_PASSWORD="dbuser123"`
- `POSTGRES_DB="myapp"`
- `POSTGRES_PORT="5000"`

To launch and initialize locally:
1. Run `calendar_database/startup.sh` to start PostgreSQL.
2. Apply the schema:
    ```
    psql -h localhost -U appuser -d myapp -p 5000 -f calendar_database/schema.sql
    ```
3. Use the Node.js viewer in `calendar_database/db_visualizer` to inspect tables/data.

**If you use a different environment or deployment, update your `.env` or those files to match your credentials.**
