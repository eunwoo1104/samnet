package dao;

import org.json.simple.JSONObject;

public class FeedObj {
    private String idx, user, content, images, replyOf, createdAt, editedAt;

    public FeedObj(String idx, String user, String content, String images, String replyOf, String createdAt, String editedAt) {
        this.idx = idx;
        this.user = user;
        this.content = content;
        this.images = images;
        this.replyOf = replyOf;
        this.createdAt = createdAt;
        this.editedAt = editedAt;
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

    public String getImages() {
        return images;
    }

    public String getReplyOf() {
        return replyOf;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public String getEditedAt() {
        return editedAt;
    }

    public JSONObject toJSON() {
        JSONObject body = new JSONObject();
        body.put("idx", idx);
        body.put("user", user);
        body.put("content", content);
        body.put("images", images);
        body.put("replyOf", replyOf);
        body.put("createdAt", createdAt);
        body.put("editedAt", editedAt);

        return body;
    }
}
