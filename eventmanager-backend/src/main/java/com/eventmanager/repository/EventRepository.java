package com.eventmanager.repository;

import com.eventmanager.model.Event;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;

public interface EventRepository extends JpaRepository<Event, Long> {
    List<Event> findByOwnerId(Long ownerId);

    @Query("SELECT e FROM Event e WHERE e.owner.id = :ownerId " +
           "AND (:query IS NULL OR LOWER(e.name) LIKE LOWER(CONCAT('%',:query,'%')) " +
           "OR LOWER(e.location) LIKE LOWER(CONCAT('%',:query,'%'))) " +
           "AND (:category IS NULL OR e.category = :category) " +
           "ORDER BY e.date ASC")
    List<Event> searchByOwner(@Param("ownerId") Long ownerId,
                               @Param("query") String query,
                               @Param("category") String category);

    Optional<Event> findByIdAndOwnerId(Long id, Long ownerId);
    Optional<Event> findByInviteToken(String token);
}
