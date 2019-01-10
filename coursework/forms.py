from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField, BooleanField, SelectField, validators


class UserLoginForm(FlaskForm):
    login = StringField('Логін: ', validators=[
        validators.DataRequired('Введіть Ваш логін')])
    password = PasswordField('Пароль: ', validators=[
        validators.DataRequired('Введіть Ваш пароль')])
    remember_me = BooleanField("Запам'ятай мене")
    submit = SubmitField('Увійти')


class UserRegistrationForm(FlaskForm):
    login = StringField('Логін:', validators=[
        validators.DataRequired('Введіть Ваш логін'),
        validators.Length(min=5, max=30, message='Допустима кількість символів для лігіна між 5 та 30')])
    name = StringField('Ім\'я:', validators=[
        validators.DataRequired('Введіть Ваше Ім\'я'),
        validators.Length(min=5, max=30, message='Допустима кількість символів в імені між 5 та 30')])
    password = PasswordField('Пароль:', validators=[
        validators.DataRequired('Введіть Ваш пароль'),
        validators.Length(min=5, max=30, message='Допустима кількість символів пароля між 5 та 30')])
    password_repeat = PasswordField('Повторіть пароль:', validators=[
        validators.DataRequired('Повторіть Ваш пароль')])
    registration = SubmitField('Зареєструватися')


class AddForm(FlaskForm):
    name = StringField('Назва:', validators=[
        validators.DataRequired('Введіть назву'),
        validators.Length(min=5, max=30, message='Допустима кількість символів для назви між 5 та 30')])
    submit = SubmitField('Додати')


def create_update_form(id_name):
    class DynamicForm(FlaskForm):
        name = SelectField('Опис: ', choices=[(name_field, name_field) for name_field in id_name])

    setattr(DynamicForm, 'new_name', StringField('Назва:', validators=[validators.DataRequired('Введіть опис')]))
    setattr(DynamicForm, 'submit', SubmitField('Оновити'))
    return DynamicForm()


def create_delete_form(id_name):
    class DynamicForm(FlaskForm):
        name = SelectField('Назва: ', choices=[(name_field, name_field) for name_field in id_name])
    setattr(DynamicForm, 'submit', SubmitField('Видалити'))
    return DynamicForm()


def create_select_form(id_user_rules, id_and_names):
    class DynamicForm(FlaskForm):
        rule_id = SelectField('Назва: ', choices=[(rule_row, rule_row) for rule_row in id_user_rules])
    for id_name in id_and_names:
        setattr(DynamicForm, id_name, BooleanField(id_name))
    setattr(DynamicForm, 'submit', SubmitField('Додати'))
    return DynamicForm()


def create_select_parametrs(param_names):
    class DynamicForm(FlaskForm):
        pass
    for param_name in param_names:
        setattr(DynamicForm, param_name, BooleanField(param_name))
    setattr(DynamicForm, 'submit', SubmitField('Побудувати пораду'))
    return DynamicForm()