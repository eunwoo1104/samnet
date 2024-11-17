CREATE DATABASE IF NOT EXISTS samnet DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE samnet;

CREATE TABLE IF NOT EXISTS user(
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY ,
    email VARCHAR(128) UNIQUE,
    password CHAR(64),
    nickname VARCHAR(32) NULL DEFAULT NULL,
    username VARCHAR(32),
    bio VARCHAR(1024) NULL DEFAULT NULL,
    avatar VARCHAR(10) NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    flag TINYINT NOT NULL DEFAULT 0
    );

CREATE TABLE IF NOT EXISTS feed(
    idx INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user INT UNSIGNED,
    content VARCHAR(4096),
    images VARCHAR(128),
    reply_of INT UNSIGNED NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user) REFERENCES user(id) ON DELETE CASCADE
    );

CREATE TABLE IF NOT EXISTS image(
    idx INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user INT UNSIGNED,
    dir VARCHAR(128),
    FOREIGN KEY (user) REFERENCES user(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS heart(
    user INT UNSIGNED NOT NULL,
    feed INT UNSIGNED NOT NULL,
    PRIMARY KEY (user, feed),
    FOREIGN KEY (user) REFERENCES user(id) ON DELETE CASCADE,
    FOREIGN KEY (feed) REFERENCES feed(idx) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS follow(
    user INT UNSIGNED NOT NULL,
    target INT UNSIGNED NOT NULL,
    PRIMARY KEY (user, target),
    FOREIGN KEY (user) REFERENCES user(id) ON DELETE CASCADE,
    FOREIGN KEY (target) REFERENCES user(id) ON DELETE CASCADE
);