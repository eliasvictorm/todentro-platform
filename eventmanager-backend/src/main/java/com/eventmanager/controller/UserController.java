package com.eventmanager.controller;

import com.eventmanager.model.User;
import com.eventmanager.repository.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserRepository userRepository;

    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    private User getUser(UserDetails ud) {
        return userRepository.findByEmail(ud.getUsername()).orElseThrow();
    }

    @GetMapping("/me")
    public ResponseEntity<UserResponse> me(@AuthenticationPrincipal UserDetails ud) {
        return ResponseEntity.ok(toResponse(getUser(ud)));
    }

    @PutMapping("/me")
    public ResponseEntity<UserResponse> update(@RequestBody UpdateRequest req,
                                                @AuthenticationPrincipal UserDetails ud) {
        User u = getUser(ud);
        if (req.name != null && !req.name.isBlank()) u.setName(req.name.trim());
        if (req.avatarUrl != null) u.setAvatarUrl(req.avatarUrl);
        userRepository.save(u);
        return ResponseEntity.ok(toResponse(u));
    }

    @GetMapping("/search")
    public ResponseEntity<List<UserResponse>> search(@RequestParam String email,
                                                      @AuthenticationPrincipal UserDetails ud) {
        User me = getUser(ud);
        List<UserResponse> results = userRepository
                .findByEmailContainingIgnoreCaseOrNameContainingIgnoreCase(email, email)
                .stream()
                .filter(u -> !u.getId().equals(me.getId()))
                .map(this::toResponse)
                .toList();
        return ResponseEntity.ok(results);
    }

    private UserResponse toResponse(User u) {
        UserResponse r = new UserResponse();
        r.id = u.getId(); r.name = u.getName();
        r.email = u.getEmail(); r.avatarUrl = u.getAvatarUrl();
        return r;
    }

    static class UpdateRequest { public String name; public String avatarUrl; }
    static class UserResponse { public Long id; public String name, email, avatarUrl; }
}
