package com.eventmanager.repository;

import com.eventmanager.model.Participant;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ParticipantRepository extends JpaRepository<Participant, Long> {
    List<Participant> findByEventId(Long eventId);
    boolean existsByEventIdAndEmail(Long eventId, String email);
}
