package dao;

public class FeedObj {
    private String idx, user, content, createdAt;

    public FeedObj(String idx, String user, String content, String createdAt) {
        this.idx = idx;
        this.user = user;
        this.content = content;
        this.createdAt = createdAt;
    }

    public String getIdx() {
        return idx;
    }

    public String getUser() {
        return user;
    }

    public String getContent() {
        return content;
    }

    public String getCreatedAt() {
        return createdAt;
    }
}
