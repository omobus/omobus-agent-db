#!/bin/sh

# Copyright (c) 2006 - 2020 omobus-agent-db authors, see the included COPYRIGHT file.

dbname=omobus-agent-db
srv=srv1
uname=omobus
passwd=omobus

fisql -I freetds.conf -S $srv -U $uname -P $passwd -D $dbname -i omobus-agent-db.sql
fisql -I freetds.conf -S $srv -U $uname -P $passwd -D $dbname -i version.sql

exit 0
# The end of the script.
