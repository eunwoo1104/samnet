package dao;

public class UserObj {
    private String id, email, nickname, username, bio, createdAt;

    public UserObj(String id, String email, String nickname, String username, String bio, String createdAt) {
        this.id = id;
        this.email = email;
        this.nickname = nickname;
        this.username = username;
        this.bio = bio;
        this.createdAt = createdAt;
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

    public String getCreatedAt() {
        return createdAt;
    }
}
