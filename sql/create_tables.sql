DROP TABLE rules_have_clothes;

DROP TABLE rules_have_parameters;

DROP TABLE user_have_parameters;

DROP TABLE clothes_rules;

DROP TABLE clothes;

DROP TABLE parametrs;

DROP TABLE user_info;

CREATE TABLE clothes (
    clothes_id             INTEGER,
    clothes_name           VARCHAR2(30),
    clothes_deleted        DATE DEFAULT NULL,
    user_info_user_login   VARCHAR2(30) NOT NULL
);

ALTER TABLE clothes ADD CONSTRAINT clothes_pk PRIMARY KEY ( clothes_id );

CREATE TABLE clothes_rules (
    rule_id INTEGER,
    rule_name VARCHAR2(30),
    rule_deleted           DATE DEFAULT NULL,
    user_info_user_login   VARCHAR2(30) NOT NULL
);

ALTER TABLE clothes_rules ADD CONSTRAINT clothes_rules_pk PRIMARY KEY ( rule_id );

CREATE TABLE parametrs (
    param_id               INTEGER,
    param_name             VARCHAR2(30),
    param_deleted          DATE DEFAULT NULL,
    user_info_user_login   VARCHAR2(30) NOT NULL
);

ALTER TABLE parametrs ADD CONSTRAINT parametrs_pk PRIMARY KEY ( param_id );

CREATE TABLE rules_have_clothes (
    clothes_clothes_id        INTEGER NOT NULL,
    clothes_rules_rule_id   INTEGER NOT NULL
);

ALTER TABLE rules_have_clothes ADD CONSTRAINT rules_have_clothes_pk PRIMARY KEY ( clothes_clothes_id,
                                                                                  clothes_rules_rule_id );

CREATE TABLE rules_have_parameters (
    parametrs_param_id        INTEGER NOT NULL,
    clothes_rules_rule_id   INTEGER NOT NULL
);

ALTER TABLE rules_have_parameters ADD CONSTRAINT rules_have_parameters_pk PRIMARY KEY ( parametrs_param_id,
                                                                                        clothes_rules_rule_id );

CREATE TABLE user_have_parameters (
    user_info_user_login   VARCHAR2(30) NOT NULL,
    parameters_param_id    INTEGER NOT NULL
);

ALTER TABLE user_have_parameters ADD CONSTRAINT user_have_parameters_pk PRIMARY KEY ( user_info_user_login,
                                                                                      parameters_param_id );

CREATE TABLE user_info (
    user_login      VARCHAR2(30),
    user_name       VARCHAR2(30),
    user_password   VARCHAR2(30)
);

ALTER TABLE user_info ADD CONSTRAINT user_info_pk PRIMARY KEY ( user_login );

ALTER TABLE clothes_rules
    ADD CONSTRAINT clothes_rules_user_info_fk FOREIGN KEY ( user_info_user_login )
        REFERENCES user_info ( user_login );

ALTER TABLE clothes
    ADD CONSTRAINT clothes_user_info_fk FOREIGN KEY ( user_info_user_login )
        REFERENCES user_info ( user_login );

ALTER TABLE parametrs
    ADD CONSTRAINT parametrs_user_info_fk FOREIGN KEY ( user_info_user_login )
        REFERENCES user_info ( user_login );

ALTER TABLE rules_have_clothes
    ADD CONSTRAINT rules_have_clothes_clo_rul_fk FOREIGN KEY ( clothes_rules_rule_id )
        REFERENCES clothes_rules ( rule_id );

ALTER TABLE rules_have_clothes
    ADD CONSTRAINT rules_have_clothes_clothes_fk FOREIGN KEY ( clothes_clothes_id )
        REFERENCES clothes ( clothes_id );

ALTER TABLE rules_have_parameters
    ADD CONSTRAINT rules_have_param_clot_rules_fk FOREIGN KEY ( clothes_rules_rule_id )
        REFERENCES clothes_rules ( rule_id );

ALTER TABLE rules_have_parameters
    ADD CONSTRAINT rules_have_param_parametrs_fk FOREIGN KEY ( parametrs_param_id )
        REFERENCES parametrs ( param_id );

ALTER TABLE user_have_parameters
    ADD CONSTRAINT user_have_param_param_fk FOREIGN KEY ( parameters_param_id )
        REFERENCES parametrs ( param_id );

ALTER TABLE user_have_parameters
    ADD CONSTRAINT user_have_param_user_info_fk FOREIGN KEY ( user_info_user_login )
        REFERENCES user_info ( user_login );