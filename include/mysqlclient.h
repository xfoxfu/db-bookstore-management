#ifndef MYSQL_CLIENT_H
#define MYSQL_CLIENT_H

#include "libmysql/mysql.h"
#include <iostream>
#include <map>
#include <stdexcept>
#include <string>
#include <vector>

typedef std::vector<std::map<std::string, std::string>> QueryResult;

// MySQL连接对象，将关于MySQL的连接操作都封装在其中
class MySQLClient
{
private:
    // 分别是主机地址，MySQL用户名，用户密码，数据库名
    std::string host, user, password, database;
    // MySQL监听端口
    unsigned int port;
    // MYSQL对象
    MYSQL mysql;

public:
    MySQLClient() {}
    // 建立连接
    MySQLClient(const char *host, unsigned int port,
                const char *user, const char *password,
                const char *database);
    // 释放连接
    ~MySQLClient();
    // 重置数据库连接
    void reset(const char *host, unsigned int port,
               const char *user, const char *password,
               const char *database);

    // 执行insert, update, delete语句，sql是对应的MySQL语句
    long long update(const char *sql);
    // 执行查询语句，将每一行抽象为一个map来返回，sql是对应的MySQL语句
    std::vector<std::map<std::string, std::string>> query(const char *sql);
    void printTable(std::vector<std::string> keys, std::vector<std::map<std::string, std::string>> &t);

private:
    // 打开MySQL连接
    void openConnection();
    // 释放MySQL连接
    void releaseConnection();

    static std::map<std::string, int> col_size;
};

// MySQL异常
class MySQLException : public std::exception
{
private:
    // 错误信息
    std::string error;
    unsigned int code;

public:
    MySQLException(unsigned int code, const char *error);
    // 返回错误信息
    const std::string &what();
    virtual const char *what() const noexcept;
    unsigned int ecode() const noexcept;

    void print() const noexcept;

    bool is_fk_no_ref() const noexcept;
    bool is_check_fail() const noexcept;
};

#endif
