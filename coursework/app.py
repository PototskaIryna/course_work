from datetime import datetime, timedelta

from flask import Flask, render_template, request, session, redirect, url_for, make_response
import cx_Oracle

from db import *
from forms import *

app = Flask(__name__)
app.secret_key = 'My_key'

user_name = 'IRA'
password = 'ira'
server = 'xe'

@app.route('/')
def index():
    user_login = session.get('login') or request.cookies.get('login')
    user = UserPackage()
    if user_login:
        return render_template('index.html', user_login=user_login, user=user)
    return redirect(url_for('login'))


@app.route('/login', methods=['GET', 'POST'])
def login():
    form = UserLoginForm()
    if request.method == 'GET':
        user_login = session.get('login') or request.cookies.get('login')
        if user_login:
            return redirect('/')
        return render_template('login.html', form=form)
    if request.method == 'POST':
        if not form.validate():
            return render_template('login.html', form=form)
        else:
            user = UserPackage()
            login_res = user.login_user(request.form['login'], request.form['password']).values[0, 0]
            if login_res == 1:
                response = make_response(redirect('/'))
                session['login'] = request.form['login']
                if request.form.get('remember_me'):
                    expires = datetime.now() + timedelta(days=60)
                    response.set_cookie('login', request.form['login'], expires=expires)
                session['login'] = request.form['login']
                return response
            elif login_res == 0:
                return render_template('login.html', form=form, problem='Невірний пароль або логін')
            else:
                return render_template('login.html', form=form, problem='А вто тут прям помилка')


@app.route('/logout')
def logout():
    if request.method == 'GET':
        response = make_response(redirect('/login'))
        response.set_cookie('login', '', expires=0)
        session['login'] = None
        return response


@app.route('/registration', methods=['GET', 'POST'])
def registration():
    form = UserRegistrationForm()
    user_login = session.get('login') or request.cookies.get('login')
    if request.method == 'POST':
        if not form.validate():
            return render_template('registration.html', form=form)
        else:
            user = UserPackage()
            if request.form['password'] == request.form['password_repeat']:
                status = user.add_user(
                    request.form['login'],
                    request.form['name'],
                    request.form['password']
                )
                if status == 'ok':
                    session['login'] = request.form['login']
                    return redirect('/')
                else:
                    problem = 'Користувач з таким іменем уже існує'
                    problem = problem if status == problem else 'Поля можуть містити лиш букви, числа та симовол "_"'
                    return render_template('registration.html', form=form, problem=problem)
            else:
                return render_template('registration.html', form=form, problem='Повторний пароль невірний')
    return render_template('registration.html', form=form)

package_map = {
    'clothes_view': ClothesPackage(),
    'parametrs_view': ParametrsPackage(),
    'rule_view': RulePackage(),
    'select_rule': {
        'clothes_view': RuleClothesPackage(),
        'parametrs_view': RuleParametersPackage()
    }
}
table_map = {
    'clothes_view': 'clothes',
    'parametrs_view': 'parametrs',
    'rule_view': 'clothes_rules'
}

id_map = {
    'clothes_view': 'clothes_id',
    'parametrs_view': 'param_id',
    'rule_view': 'rule_id'
}


@app.route('/show_table/<table_name>')
def show_table(table_name):
    sql = "select * from {}".format(table_name)
    conn = cx_Oracle.connect(user_name, password, server)
    table = pd.read_sql_query(sql, conn, index_col=id_map[table_name].upper())
    return render_template('show_table.html', table=table.to_html(), table_name=table_name)


@app.route('/add_table/<table_name>', methods=['GET', 'POST'])
def add_table(table_name):
    user_login = session.get('login') or request.cookies.get('login')
    form = AddForm()
    problem = None
    if request.method == 'POST':
        if not form.validate():
            pass
        else:
            package = package_map[table_name]
            sql = 'SELECT {} from {}'.format(id_map[table_name], table_map[table_name])
            conn = cx_Oracle.connect(user_name, password, server)
            try:
                clothes_id = int(pd.read_sql_query(sql, conn).values[:, 0].max()) + 1
            except:
                clothes_id = 0
            status = package.add(clothes_id, request.form['name'], user_login)
            if status == 'ok':
                return redirect(url_for('show_table', table_name=table_name))
            else:
                problem = 'Такий id уже існує'
                problem = problem if status == problem else 'Поля можуть містити лиш букви, числа та симовол "_"'
    return render_template('add_table.html',
                           user_login=user_login,
                           table_name=table_name,
                           form=form,
                           problem=problem)


@app.route('/update_table/<table_name>', methods=['GET', 'POST'])
def update_table(table_name):
    user_login = session.get('login') or request.cookies.get('login')
    sql = "SELECT {}, {} from {} where user_info_user_login='{}'".format(id_map[table_name].split('_')[0]+'_name',
                                                                       id_map[table_name], table_name, user_login)
    conn = cx_Oracle.connect(user_name, password, server)
    id_name_table = pd.read_sql_query(sql, conn)
    id_name = (id_name_table[id_map[table_name].upper()].astype(str) + '~' +
               id_name_table[(id_map[table_name].split('_')[0]+'_name').upper()].astype(str))

    form = create_update_form(id_name)
    problem = None
    if request.method == 'POST':
        if not form.validate():
            pass
        else:
            package = package_map[table_name]
            status = package.update(request.form['name'].split('~')[0], request.form['new_name'])
            if status == 'ok':
                return redirect(url_for('show_table', table_name=table_name))
            else:
                problem = 'Поля можуть містити лиш букви, числа та симовол "_"'
    return render_template('update_table.html',
                           user_login=user_login,
                           table_name=table_name,
                           form=form,
                           problem=problem)


@app.route('/delete_table/<table_name>', methods=['GET', 'POST'])
def delete_table(table_name):
    user_login = session.get('login') or request.cookies.get('login')
    sql = "SELECT {}, {} from {} where user_info_user_login='{}'".format(id_map[table_name].split('_')[0]+'_name',
                                                                       id_map[table_name], table_name, user_login)
    conn = cx_Oracle.connect(user_name, password, server)
    id_name_table = pd.read_sql_query(sql, conn)
    id_name = (id_name_table[id_map[table_name].upper()].astype(str) + '~' +
               id_name_table[(id_map[table_name].split('_')[0]+'_name').upper()].astype(str))
    form = create_delete_form(id_name)
    problem = None
    if request.method == 'POST':
        if not form.validate():
            pass
        else:
            package = package_map[table_name]
            status = package.delete(request.form['name'].split('~')[0])
            if status == 'ok':
                return redirect(url_for('show_table', table_name=table_name))
            else:
                problem = 'Оберіть назву з випадаючого списка'
    return render_template('delete_table.html',
                           user_login=user_login,
                           form=form,
                           table_name=table_name,
                           problem=problem)


@app.route('/add_to_rule/<select_name>', methods=['GET', 'POST'])
def add_to_rule(select_name):
    user_login = session.get('login') or request.cookies.get('login')
    conn = cx_Oracle.connect(user_name, password, server)

    sql_user_rules = "SELECT RULE_ID, RULE_NAME FROM RULE_VIEW WHERE USER_INFO_USER_LOGIN = '{}'".format(user_login)
    id_user_rules_df = pd.read_sql_query(sql_user_rules, conn)
    id_user_rules = list(id_user_rules_df.iloc[:, 0].astype(str) + '~' + id_user_rules_df.iloc[:, 1].astype(str))

    sql_id_and_names = "SELECT {}, {} FROM {}".format(id_map[select_name], id_map[select_name].split('_')[0]+'_name', select_name)
    id_and_names_df = pd.read_sql_query(sql_id_and_names, conn)
    id_and_names = list(id_and_names_df.iloc[:, 0].astype(str) + '~' + id_and_names_df.iloc[:, 1].astype(str))

    form = create_select_form(id_user_rules, id_and_names)

    problem = None
    if request.method == 'POST':
        if not form.validate():
            pass
        else:
            package = package_map['select_rule'][select_name]
            status = package.delete(request.form['rule_id'].split('~')[0])
            id_names = list(filter(lambda x: x not in ('csrf_token', 'submit', 'rule_id'), request.form))
            for id_name in id_names:
                status = package.add(id_name.split('~')[0], request.form['rule_id'].split('~')[0])
                if status != 'ok':
                    problem = 'Оберіть назву з випадаючого списка'
                    break
            if status == 'ok':
                return redirect(url_for('show_table', table_name=select_name))
            else:
                problem = 'Оберіть назву з випадаючого списка'
    return render_template('select_rule.html',
                           user_login=user_login,
                           form=form,
                           table_name=select_name,
                           problem=problem)


@app.route('/table/<table_name>')
def table(table_name):
    conn = cx_Oracle.connect(user_name, password, server)
    sql = "SELECT * FROM {}".format(table_name)
    df = pd.read_sql_query(sql, conn)
    return  render_template('all_select_rules.html', table=df.to_html())


@app.route('/select_prametrs', methods=['GET', 'POST'])
def select_prametrs():
    user_login = session.get('login') or request.cookies.get('login')
    conn = cx_Oracle.connect(user_name, password, server)
    sql1 = "SELECT PARAM_ID, PARAM_NAME FROM PARAMETRS_VIEW"
    df = pd.read_sql_query(sql1, conn)
    param_names = list(df.iloc[:, 0].astype(str) + '~' + df.iloc[:, 1].astype(str))
    form = create_select_parametrs(param_names)
    res = pd.DataFrame()
    if request.method == 'POST':
        if not form.validate():
            pass
        else:
            selected_param = list(filter(lambda x: x not in ('csrf_token', 'submit'), request.form))
            selected_ids = [param.split('~')[0] for param in selected_param]
            if selected_ids:
                sql2 = '''
                SELECT 
                    DISTINCT CLOTHES_RULES.RULE_NAME,
                    CLOTHES_RULES.RULE_ID
                FROM RULES_HAVE_PARAMETERS
                    JOIN PARAMETRS ON PARAMETRS.PARAM_ID = RULES_HAVE_PARAMETERS.PARAMETRS_PARAM_ID
                    JOIN RULES_HAVE_CLOTHES ON RULES_HAVE_CLOTHES.CLOTHES_RULES_RULE_ID = RULES_HAVE_PARAMETERS.CLOTHES_RULES_RULE_ID
                    JOIN CLOTHES_RULES ON CLOTHES_RULES.RULE_ID = RULES_HAVE_CLOTHES.CLOTHES_RULES_RULE_ID  
                    
                WHERE
                    PARAMETRS.PARAM_ID IN ({})
                '''.format(', '.join(selected_ids))
                res = pd.read_sql_query(sql2, conn)
                res.RULE_ID = res.RULE_ID.apply(lambda x: '<a href="/info/{0}">{0}</a>'.format(x))
                return render_template('select_parametrs.html',
                                       table=res,  form=form)
    return render_template('select_parametrs.html',  form=form, table=res)


@app.route('/info/<rule_name>')
def info(rule_name):
    user_login = session.get('login') or request.cookies.get('login')
    conn = cx_Oracle.connect(user_name, password, server)
    sql = '''
        SELECT CLOTHES.CLOTHES_NAME 
            FROM CLOTHES 
            JOIN RULES_HAVE_CLOTHES ON CLOTHES.CLOTHES_ID = RULES_HAVE_CLOTHES.CLOTHES_CLOTHES_ID
        WHERE RULES_HAVE_CLOTHES.CLOTHES_RULES_RULE_ID = {}
    '''.format(rule_name)
    res = pd.read_sql_query(sql, conn)
    return render_template('show_info.html', table=res.to_html())


if __name__ == '__main__':
    app.run(debug=True)
