USE samnet;
DROP PROCEDURE IF EXISTS toggleHeart;

DELIMITER //

CREATE PROCEDURE toggleHeart(
    IN uid INT UNSIGNED, IN idx INT UNSIGNED, OUT result BOOLEAN, OUT hearts INT
)
BEGIN
    DECLARE voted INT;
    SELECT COUNT(*) INTO voted FROM heart WHERE user=uid AND feed=idx;
    IF voted != 0 THEN
        DELETE FROM heart WHERE user=uid AND feed=idx;
        SET result = FALSE;
    ELSE
        INSERT INTO heart(user, feed) VALUES (uid, idx);
        SET result = TRUE;
    END IF;
    SELECT COUNT(*) INTO hearts FROM heart WHERE feed=idx;
END //

CREATE PROCEDURE toggleFollow(
    IN uid INT UNSIGNED, IN target_user INT UNSIGNED, OUT result BOOLEAN
)
BEGIN
    DECLARE followed INT;
    SELECT COUNT(*) INTO followed FROM follow WHERE user=uid AND target=target_user;
    IF followed != 0 THEN
        DELETE FROM follow WHERE user=uid AND target=target_user;
        SET result = FALSE;
    ELSE
        INSERT INTO follow(user, target) VALUES (uid, target_user);
        SET result = TRUE;
    END IF;
end //

DELIMITER ;