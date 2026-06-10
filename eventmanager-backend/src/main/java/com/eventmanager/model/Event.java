package com.eventmanager.model;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "events")
public class Event {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false)
    private LocalDate date;

    @Column(nullable = false)
    private LocalTime time;

    @Column(nullable = false)
    private String location;

    @Column(nullable = false)
    private int maxParticipants;

    @Column(nullable = false)
    private String category;

    @Column(columnDefinition = "TEXT")
    private String coverImageUrl;

    @Column(unique = true)
    private String inviteToken;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    private User owner;

    @OneToMany(mappedBy = "event", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Participant> participants = new ArrayList<>();

    @OneToMany(mappedBy = "event", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Invite> invites = new ArrayList<>();

    public boolean hasAvailableSlots() { return participants.size() < maxParticipants; }
    public int getAvailableSlots() { return maxParticipants - participants.size(); }

    public String generateInviteToken() {
        this.inviteToken = UUID.randomUUID().toString().replace("-", "").substring(0, 12);
        return this.inviteToken;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public LocalDate getDate() { return date; }
    public void setDate(LocalDate date) { this.date = date; }
    public LocalTime getTime() { return time; }
    public void setTime(LocalTime time) { this.time = time; }
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    public int getMaxParticipants() { return maxParticipants; }
    public void setMaxParticipants(int v) { this.maxParticipants = v; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getCoverImageUrl() { return coverImageUrl; }
    public void setCoverImageUrl(String coverImageUrl) { this.coverImageUrl = coverImageUrl; }
    public String getInviteToken() { return inviteToken; }
    public void setInviteToken(String inviteToken) { this.inviteToken = inviteToken; }
    public User getOwner() { return owner; }
    public void setOwner(User owner) { this.owner = owner; }
    public List<Participant> getParticipants() { return participants; }
    public void setParticipants(List<Participant> p) { this.participants = p; }
    public List<Invite> getInvites() { return invites; }
    public void setInvites(List<Invite> invites) { this.invites = invites; }
}
