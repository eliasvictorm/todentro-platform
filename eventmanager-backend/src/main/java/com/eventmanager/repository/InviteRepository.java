package com.eventmanager.repository;

import com.eventmanager.model.Invite;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface InviteRepository extends JpaRepository<Invite, Long> {
    List<Invite> findByInviteeIdOrderByCreatedAtDesc(Long inviteeId);
    List<Invite> findByEventId(Long eventId);
    Optional<Invite> findByEventIdAndInviteeId(Long eventId, Long inviteeId);
    Optional<Invite> findByEventIdAndInviteeEmail(Long eventId, String email);
    boolean existsByEventIdAndInviteeId(Long eventId, Long inviteeId);
    boolean existsByEventIdAndInviteeEmail(Long eventId, String email);
}
