package com.eventmanager.controller;

import com.eventmanager.model.*;
import com.eventmanager.repository.*;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/events")
public class EventController {

    private final EventRepository eventRepo;
    private final ParticipantRepository participantRepo;
    private final UserRepository userRepo;

    public EventController(EventRepository eventRepo, ParticipantRepository participantRepo,
                           UserRepository userRepo) {
        this.eventRepo = eventRepo;
        this.participantRepo = participantRepo;
        this.userRepo = userRepo;
    }

    private User getUser(UserDetails ud) {
        return userRepo.findByEmail(ud.getUsername()).orElseThrow();
    }

    private EventController.EventResponse toResponse(Event e) {
        EventController.EventResponse r = new EventController.EventResponse();
        r.id = e.getId(); r.name = e.getName(); r.description = e.getDescription();
        r.date = e.getDate(); r.time = e.getTime(); r.location = e.getLocation();
        r.maxParticipants = e.getMaxParticipants(); r.category = e.getCategory();
        r.coverImageUrl = e.getCoverImageUrl(); r.inviteToken = e.getInviteToken();
        r.participantCount = e.getParticipants().size();
        r.availableSlots = e.getAvailableSlots();
        r.ownerName = e.getOwner().getName(); r.ownerId = e.getOwner().getId();
        return r;
    }

    private EventController.ParticipantResponse toPResponse(Participant p) {
        EventController.ParticipantResponse r = new EventController.ParticipantResponse();
        r.id = p.getId(); r.name = p.getName(); r.email = p.getEmail();
        r.phone = p.getPhone(); r.paid = p.isPaid();
        return r;
    }

    @GetMapping
    public List<EventController.EventResponse> list(@RequestParam(required = false) String query,
                                     @RequestParam(required = false) String category,
                                     @AuthenticationPrincipal UserDetails ud) {
        return eventRepo.searchByOwner(getUser(ud).getId(), query, category)
                .stream().map(this::toResponse).toList();
    }

    @GetMapping("/{id}")
    public ResponseEntity<EventController.EventResponse> get(@PathVariable Long id,
                                              @AuthenticationPrincipal UserDetails ud) {
        return eventRepo.findByIdAndOwnerId(id, getUser(ud).getId())
                .map(e -> ResponseEntity.ok(toResponse(e)))
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<EventController.EventResponse> create(@Valid @RequestBody EventController.EventRequest req,
                                                 @AuthenticationPrincipal UserDetails ud) {
        Event e = new Event();
        apply(e, req); e.setOwner(getUser(ud)); e.generateInviteToken();
        return ResponseEntity.ok(toResponse(eventRepo.save(e)));
    }

    @PutMapping("/{id}")
    public ResponseEntity<EventController.EventResponse> update(@PathVariable Long id,
                                                 @Valid @RequestBody EventController.EventRequest req,
                                                 @AuthenticationPrincipal UserDetails ud) {
        return eventRepo.findByIdAndOwnerId(id, getUser(ud).getId())
                .map(e -> { apply(e, req); return ResponseEntity.ok(toResponse(eventRepo.save(e))); })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id, @AuthenticationPrincipal UserDetails ud) {
        return eventRepo.findByIdAndOwnerId(id, getUser(ud).getId())
                .map(e -> { eventRepo.delete(e); return ResponseEntity.ok().<Void>build(); })
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/{id}/generate-link")
    public ResponseEntity<Map<String, String>> generateLink(@PathVariable Long id, @AuthenticationPrincipal UserDetails ud) {
        return eventRepo.findByIdAndOwnerId(id, getUser(ud).getId())
                .map(e -> {
                    if (e.getInviteToken() == null) e.generateInviteToken();
                    eventRepo.save(e);
                    return ResponseEntity.ok(Map.of(
                            "token", e.getInviteToken(),
                            "link", "todentro://invite/" + e.getInviteToken()));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/invite/{token}")
    public ResponseEntity<EventController.EventResponse> getByToken(@PathVariable String token) {
        return eventRepo.findByInviteToken(token)
                .map(e -> ResponseEntity.ok(toResponse(e)))
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/invite/{token}/join")
    public ResponseEntity<?> join(@PathVariable String token, @Valid @RequestBody EventController.ParticipantRequest req) {
        return eventRepo.findByInviteToken(token)
                .map(e -> joinEvent(e, req))
                .orElse(ResponseEntity.notFound().build());
    }

    private ResponseEntity<?> joinEvent(Event e, EventController.ParticipantRequest req) {
        if (!e.hasAvailableSlots())
            return ResponseEntity.badRequest().body(Map.of("error", "Evento lotado."));
        if (participantRepo.existsByEventIdAndEmail(e.getId(), req.email))
            return ResponseEntity.badRequest().body(Map.of("error", "Você já está nesse rolê!"));
        Participant p = new Participant();
        p.setName(req.name); p.setEmail(req.email); p.setPhone(req.phone); p.setEvent(e);
        e.getParticipants().add(p);
        eventRepo.save(e);
        return ResponseEntity.ok(toPResponse(p));
    }

    @GetMapping("/{id}/participants")
    public ResponseEntity<List<EventController.ParticipantResponse>> listPart(@PathVariable Long id,
                                                               @AuthenticationPrincipal UserDetails ud) {
        return eventRepo.findByIdAndOwnerId(id, getUser(ud).getId())
                .map(e -> ResponseEntity.ok(e.getParticipants().stream().map(this::toPResponse).toList()))
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/{id}/participants")
    public ResponseEntity<?> addPart(@PathVariable Long id, @Valid @RequestBody EventController.ParticipantRequest req,
                                      @AuthenticationPrincipal UserDetails ud) {
        return eventRepo.findByIdAndOwnerId(id, getUser(ud).getId())
                .map(e -> addParticipant(e, req))
                .orElse(ResponseEntity.notFound().build());
    }

    private ResponseEntity<?> addParticipant(Event e, EventController.ParticipantRequest req) {
        if (!e.hasAvailableSlots())
            return ResponseEntity.badRequest().body(Map.of("error", "Evento lotado."));
        if (participantRepo.existsByEventIdAndEmail(e.getId(), req.email))
            return ResponseEntity.badRequest().body(Map.of("error", "Participante já cadastrado."));
        Participant p = new Participant();
        p.setName(req.name); p.setEmail(req.email); p.setPhone(req.phone); p.setEvent(e);
        e.getParticipants().add(p);
        eventRepo.save(e);
        return ResponseEntity.ok(toPResponse(p));
    }

    @DeleteMapping("/{id}/participants/{pid}")
    public ResponseEntity<Void> removePart(@PathVariable Long id, @PathVariable Long pid,
                                            @AuthenticationPrincipal UserDetails ud) {
        return eventRepo.findByIdAndOwnerId(id, getUser(ud).getId())
                .map(e -> {
                    e.getParticipants().removeIf(p -> p.getId().equals(pid));
                    eventRepo.save(e);
                    return ResponseEntity.ok().<Void>build();
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}/participants/{pid}/paid")
    public ResponseEntity<?> togglePaid(@PathVariable Long id, @PathVariable Long pid,
                                         @RequestBody Map<String, Boolean> body,
                                         @AuthenticationPrincipal UserDetails ud) {
        return eventRepo.findByIdAndOwnerId(id, getUser(ud).getId())
                .map(e -> {
                    e.getParticipants().stream().filter(p -> p.getId().equals(pid)).findFirst()
                            .ifPresent(p -> p.setPaid(body.getOrDefault("paid", !p.isPaid())));
                    eventRepo.save(e);
                    return ResponseEntity.ok(Map.of("ok", true));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    private void apply(Event e, EventController.EventRequest req) {
        e.setName(req.name); e.setDescription(req.description);
        e.setDate(req.date); e.setTime(req.time); e.setLocation(req.location);
        e.setMaxParticipants(req.maxParticipants); e.setCategory(req.category);
        e.setCoverImageUrl(req.coverImageUrl);
    }

    public static class EventRequest {
        @NotBlank public String name; public String description;
        @NotNull public LocalDate date; @NotNull public LocalTime time;
        @NotBlank public String location; @Min(1) public int maxParticipants;
        @NotBlank public String category; public String coverImageUrl;
    }
    public static class EventResponse {
        public Long id, ownerId; public String name, description, location, category;
        public String coverImageUrl, inviteToken, ownerName;
        public LocalDate date; public LocalTime time;
        public int maxParticipants, participantCount, availableSlots;
    }
    public static class ParticipantRequest {
        @NotBlank public String name; @Email @NotBlank public String email; public String phone;
    }
    public static class ParticipantResponse {
        public Long id; public String name, email, phone; public boolean paid;
    }
}
