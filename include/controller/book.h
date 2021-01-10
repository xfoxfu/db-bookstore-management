#pragma once

#include "mysqlclient.h"

namespace book
{
    void menu(MySQLClient &client);
    void list(MySQLClient &client);
    void query(MySQLClient &client);
    void create(MySQLClient &client);
    void update(MySQLClient &client);
    void remove(MySQLClient &client);
}; // namespace book
