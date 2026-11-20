package com.gateprogress.progress;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "study_progress")
public class StudyProgress {
    @Id
    private String id = "default";

    private List<String> completedTopics = new ArrayList<>();
    private List<Map<String, Object>> studySessions = new ArrayList<>();
    private Instant updatedAt = Instant.now();

    public StudyProgress() {}

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public List<String> getCompletedTopics() {
        return completedTopics;
    }

    public void setCompletedTopics(List<String> completedTopics) {
        this.completedTopics = completedTopics;
    }

    public List<Map<String, Object>> getStudySessions() {
        return studySessions;
    }

    public void setStudySessions(List<Map<String, Object>> studySessions) {
        this.studySessions = studySessions;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Instant updatedAt) {
        this.updatedAt = updatedAt;
    }
}
