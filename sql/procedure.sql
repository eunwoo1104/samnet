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

DELIMITER ;