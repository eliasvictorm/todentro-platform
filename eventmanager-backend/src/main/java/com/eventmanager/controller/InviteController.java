package com.eventmanager.controller;

import com.eventmanager.model.*;
import com.eventmanager.repository.*;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/invites")
public class InviteController {

    private final InviteRepository inviteRepo;
    private final EventRepository eventRepo;
    private final UserRepository userRepo;
    private final ParticipantRepository participantRepo;

    public InviteController(InviteRepository inviteRepo, EventRepository eventRepo,
                             UserRepository userRepo, ParticipantRepository participantRepo) {
        this.inviteRepo = inviteRepo;
        this.eventRepo = eventRepo;
        this.userRepo = userRepo;
        this.participantRepo = participantRepo;
    }

    private User getUser(UserDetails ud) {
        return userRepo.findByEmail(ud.getUsername()).orElseThrow();
    }

    // GET /api/invites/me
    @GetMapping("/me")
    public ResponseEntity<List<InviteController.InviteResponse>> myInvites(@AuthenticationPrincipal UserDetails ud) {
        User me = getUser(ud);
        return ResponseEntity.ok(
                inviteRepo.findByInviteeIdOrderByCreatedAtDesc(me.getId())
                        .stream().map(this::toResponse).toList());
    }

    // POST /api/invites/send
    @PostMapping("/send")
    public ResponseEntity<?> send(@RequestBody InviteController.SendRequest req,
                                   @AuthenticationPrincipal UserDetails ud) {
        User inviter = getUser(ud);

        Event event = eventRepo.findByIdAndOwnerId(req.eventId, inviter.getId()).orElse(null);
        if (event == null)
            return ResponseEntity.status(403).body(Map.of("error", "Apenas o criador pode convidar."));

        if (req.inviteeId != null) {
            if (inviteRepo.existsByEventIdAndInviteeId(req.eventId, req.inviteeId))
                return ResponseEntity.badRequest().body(Map.of("error", "Usuário já convidado."));
            User invitee = userRepo.findById(req.inviteeId).orElse(null);
            if (invitee == null) return ResponseEntity.notFound().build();
            Invite inv = new Invite();
            inv.setEvent(event); inv.setInviter(inviter);
            inv.setInvitee(invitee); inv.setInviteeEmail(invitee.getEmail());
            return ResponseEntity.ok(toResponse(inviteRepo.save(inv)));
        }

        if (req.email != null && !req.email.isBlank()) {
            if (inviteRepo.existsByEventIdAndInviteeEmail(req.eventId, req.email))
                return ResponseEntity.badRequest().body(Map.of("error", "E-mail já convidado."));
            User invitee = userRepo.findByEmail(req.email).orElse(null);
            Invite inv = new Invite();
            inv.setEvent(event); inv.setInviter(inviter); inv.setInviteeEmail(req.email);
            if (invitee != null) inv.setInvitee(invitee);
            return ResponseEntity.ok(toResponse(inviteRepo.save(inv)));
        }

        return ResponseEntity.badRequest().body(Map.of("error", "Informe userId ou email."));
    }

    // PUT /api/invites/{id}/respond
    @PutMapping("/{id}/respond")
    public ResponseEntity<?> respond(@PathVariable Long id,
                                      @RequestBody InviteController.RespondRequest req,
                                      @AuthenticationPrincipal UserDetails ud) {
        User me = getUser(ud);
        Invite inv = inviteRepo.findById(id).orElse(null);
        if (inv == null) return ResponseEntity.notFound().build();
        if (inv.getInvitee() == null || !inv.getInvitee().getId().equals(me.getId()))
            return ResponseEntity.status(403).build();

        if ("ACCEPTED".equals(req.response)) {
            inv.setStatus(Invite.Status.ACCEPTED);
            Event event = inv.getEvent();
            if (event.hasAvailableSlots() &&
                    !participantRepo.existsByEventIdAndEmail(event.getId(), me.getEmail())) {
                Participant p = new Participant();
                p.setName(me.getName()); p.setEmail(me.getEmail()); p.setEvent(event);
                event.getParticipants().add(p);
                eventRepo.save(event);
            }
        } else {
            inv.setStatus(Invite.Status.DECLINED);
        }
        return ResponseEntity.ok(toResponse(inviteRepo.save(inv)));
    }

    // DELETE /api/invites/{id}
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id,
                                        @AuthenticationPrincipal UserDetails ud) {
        User me = getUser(ud);
        return inviteRepo.findById(id)
                .filter(i -> i.getInvitee() != null && i.getInvitee().getId().equals(me.getId()))
                .map(i -> deleteInvite(i))
                .orElse(ResponseEntity.notFound().build());
    }

    private ResponseEntity<Void> deleteInvite(Invite i) {
        inviteRepo.delete(i);
        return ResponseEntity.ok().build();
    }

    private InviteResponse toResponse(Invite i) {
        InviteResponse r = new InviteResponse();
        r.id = i.getId();
        r.status = i.getStatus().name();
        r.inviterName = i.getInviter().getName();
        r.inviterEmail = i.getInviter().getEmail();
        r.eventId = i.getEvent().getId();
        r.eventName = i.getEvent().getName();
        r.eventDate = i.getEvent().getDate();
        r.eventTime = i.getEvent().getTime();
        r.eventLocation = i.getEvent().getLocation();
        r.eventCategory = i.getEvent().getCategory();
        r.eventCoverImageUrl = i.getEvent().getCoverImageUrl();
        r.createdAt = i.getCreatedAt().toString();
        return r;
    }

    public static class SendRequest {
        public Long eventId; public Long inviteeId; public String email;
    }
    public static class RespondRequest { public String response; }
    public static class InviteResponse {
        public Long id, eventId;
        public String status, inviterName, inviterEmail;
        public String eventName, eventLocation, eventCategory, eventCoverImageUrl, createdAt;
        public LocalDate eventDate; public LocalTime eventTime;
    }
}
