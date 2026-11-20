package com.gateprogress.progress;

import org.springframework.data.mongodb.repository.MongoRepository;

public interface StudyProgressRepository
        extends MongoRepository<StudyProgress, String> {
}
