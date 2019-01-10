import cx_Oracle
import pandas as pd

user_name = 'IRA'
password = 'ira'
server = 'xe'


class UserPackage:
    def __init__(self):
        self.__db = cx_Oracle.connect(user_name, password, server)
        self.__cursor = self.__db.cursor()

    def add_user(self, login, name, password):
        status = self.__cursor.var(cx_Oracle.STRING)
        self.__cursor.callproc('user_package.add_user', [status, login, name, password])
        return status.getvalue()

    def del_user(self, login):
        self.__cursor.callproc('user_package.del_user', [login])

    def get_user_info(self, login):
        sql = "SELECT * FROM TABLE(user_package.get_user_info('{}'))".format(login)
        res = pd.read_sql_query(sql, self.__db)
        return res

    def login_user(self, login, password):
        sql = "SELECT user_package.login_user('{}', '{}') FROM dual".format(login, password)
        res = pd.read_sql_query(sql, self.__db)
        return res

    def update_user_info(self, login, name):
        status = self.__cursor.var(cx_Oracle.STRING)
        self.__cursor.callproc('user_package.update_user_info', [status, login, name])
        return status.getvalue()


class ClothesPackage:
    def __init__(self):
        self.__db = cx_Oracle.connect(user_name, password, server)
        self.__cursor = self.__db.cursor()

    def add(self, clothes_id, clothes_name, user_login):
        status = self.__cursor.var(cx_Oracle.STRING)
        self.__cursor.callproc('clothes_package.add_clothes', [status, clothes_id, clothes_name, user_login])
        return status.getvalue()

    def delete(self, clothes_id):
        status = self.__cursor.var(cx_Oracle.STRING)
        self.__cursor.callproc('clothes_package.del_clothes', [status, clothes_id])
        return status.getvalue()

    def update(self, clothes_id, clothes_name):
        status = self.__cursor.var(cx_Oracle.STRING)
        self.__cursor.callproc('clothes_package.update_clothes', [status, clothes_id, clothes_name])
        return status.getvalue()

    def get_user_clothes(self, user_login):
        sql = "SELECT * FROM TABLE(clothes_package.get_user_clothes('{}'))".format(user_login)
        res = pd.read_sql_query(sql, self.__db)
        return res


class ParametrsPackage:
    def __init__(self):
        self.__db = cx_Oracle.connect(user_name, password, server)
        self.__cursor = self.__db.cursor()

    def add(self, param_id, param_name, user_login):
        status = self.__cursor.var(cx_Oracle.STRING)
        self.__cursor.callproc('parametrs_package.add_parametrs', [status, param_id, param_name, user_login])
        return status.getvalue()

    def delete(self, param_id):
        status = self.__cursor.var(cx_Oracle.STRING)
        self.__cursor.callproc('parametrs_package.del_parametrs', [status, param_id])
        return status.getvalue()

    def update(self, param_id, param_name):
        status = self.__cursor.var(cx_Oracle.STRING)
        self.__cursor.callproc('parametrs_package.update_parametrs', [status, param_id, param_name])
        return status.getvalue()

    def get_user_clothes(self, user_login):
        sql = "SELECT * FROM TABLE(clothes_package.get_user_clothes('{}'))".format(user_login)
        res = pd.read_sql_query(sql, self.__db)
        return res


class RulePackage:
    def __init__(self):
        self.__db = cx_Oracle.connect(user_name, password, server)
        self.__cursor = self.__db.cursor()

    def add(self, rule_id, rule_name, user_login):
        status = self.__cursor.var(cx_Oracle.STRING)
        self.__cursor.callproc('rule_package.add_rule', [status, rule_id, rule_name, user_login])
        return status.getvalue()

    def delete(self, rule_id):
        status = self.__cursor.var(cx_Oracle.STRING)
        self.__cursor.callproc('rule_package.del_rule', [status, rule_id])
        return status.getvalue()

    def update(self, rule_id, rule_name):
        status = self.__cursor.var(cx_Oracle.STRING)
        self.__cursor.callproc('rule_package.update_rule', [status, rule_id, rule_name])
        return status.getvalue()

    def get_user_clothes(self, user_login):
        sql = "SELECT * FROM TABLE(rule_package.get_user_rule('{}'))".format(user_login)
        res = pd.read_sql_query(sql, self.__db)
        return res


class RuleClothesPackage:
    def __init__(self):
        self.__db = cx_Oracle.connect(user_name, password, server)
        self.__cursor = self.__db.cursor()

    def add(self, clothes_id, rule_id):
        status = self.__cursor.var(cx_Oracle.STRING)
        self.__cursor.callproc('rule_clothes_package.add_rule_clothes', [status, clothes_id, rule_id])
        return status.getvalue()

    def delete(self, rule_id):
        status = self.__cursor.var(cx_Oracle.STRING)
        self.__cursor.callproc('rule_clothes_package.del_rule_clothes', [status, rule_id])
        return status.getvalue()


class RuleParametersPackage:
    def __init__(self):
        self.__db = cx_Oracle.connect(user_name, password, server)
        self.__cursor = self.__db.cursor()

    def add(self, param_id, rule_id):
        status = self.__cursor.var(cx_Oracle.STRING)
        self.__cursor.callproc('rule_parameters_package.add_rule_parameters', [status, param_id, rule_id])
        return status.getvalue()

    def delete(self, rule_id):
        status = self.__cursor.var(cx_Oracle.STRING)
        self.__cursor.callproc('rule_parameters_package.del_rule_parameters', [status, rule_id])
        return status.getvalue()
