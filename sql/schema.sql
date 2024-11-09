CREATE DATABASE IF NOT EXISTS samnet DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE samnet;

CREATE TABLE IF NOT EXISTS user(
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY ,
    email VARCHAR(128) UNIQUE,
    password VARCHAR(32),
    nickname VARCHAR(32) NULL DEFAULT NULL,
    username VARCHAR(32),
    bio VARCHAR(1024) NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

CREATE TABLE IF NOT EXISTS feed(
    idx INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user INT UNSIGNED,
    content VARCHAR(4096),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
