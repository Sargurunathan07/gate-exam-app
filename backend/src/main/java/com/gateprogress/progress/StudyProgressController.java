package com.gateprogress.progress;

import java.time.Instant;
import java.util.ArrayList;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/progress")
public class StudyProgressController {
    private static final String PROGRESS_ID = "default";

    private final StudyProgressRepository repository;

    public StudyProgressController(StudyProgressRepository repository) {
        this.repository = repository;
    }

    @GetMapping
    public StudyProgress getProgress() {
        return repository.findById(PROGRESS_ID)
                .orElseGet(StudyProgress::new);
    }

    @PutMapping
    public StudyProgress saveProgress(@RequestBody StudyProgress progress) {
        progress.setId(PROGRESS_ID);
        progress.setUpdatedAt(Instant.now());

        if (progress.getCompletedTopics() == null) {
            progress.setCompletedTopics(new ArrayList<>());
        }
        if (progress.getStudySessions() == null) {
            progress.setStudySessions(new ArrayList<>());
        }

        return repository.save(progress);
    }
}
