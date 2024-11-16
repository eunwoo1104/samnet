package dao;

import org.json.simple.JSONObject;

public class UserObj {
    private String id, email, nickname, username, bio, avatar, createdAt;
    private int flag;

    private final int ADMIN = 1 << 0;
    private final int VERIFIED = 1 << 1;
    private final int BLOCKED = 1 << 2;

    public UserObj(String id, String email, String nickname, String username, String bio, String avatar, String createdAt, int flag) {
        this.id = id;
        this.email = email;
        this.nickname = nickname;
        this.username = username;
        this.bio = bio;
        this.avatar = avatar;
        this.createdAt = createdAt;
        this.flag = flag;
    }

    public String getId() {
        return id;
    }

    public String getEmail() {
        return email;
    }

    public String getNickname() {
        return nickname;
    }

    public String getUsername() {
        return username;
    }

    public String getBio() {
        return bio;
    }

    public String getAvatar() {
        return avatar;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public boolean isAdmin() {
        return (flag & ADMIN) != 0;
    }

    public boolean isVerified() {
        return (flag & VERIFIED) != 0;
    }

    public boolean isBlocked() {
        return (flag & BLOCKED) != 0;
    }

    public JSONObject toJSON() {
        JSONObject body = new JSONObject();
        body.put("id", id);
        body.put("email", email);
        body.put("nickname", nickname);
        body.put("username", username);
        body.put("bio", bio);
        body.put("avatar", avatar);
        body.put("createdAt", createdAt);
        body.put("flag", flag);

        return body;
    }
}
