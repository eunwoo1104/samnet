package dao;

public class FeedObj {
    private String idx, user, content, images, replyOf, createdAt;

    public FeedObj(String idx, String user, String content, String images, String replyOf, String createdAt) {
        this.idx = idx;
        this.user = user;
        this.content = content;
        this.images = images;
        this.replyOf = replyOf;
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

    public String getSafeContent() {
        String res = content;
        res = res.replace("&", "&amp;");
        res = res.replace("<", "&lt;");
        res = res.replace(">", "&gt;");
        res = res.replace("\"", "&quot;");
        res = res.replace("'", "&#039;");

        return res;
    }

    public String getImages() {
        return images;
    }

    public String getReplyOf() {
        return replyOf;
    }

    public String getCreatedAt() {
        return createdAt;
    }
}
