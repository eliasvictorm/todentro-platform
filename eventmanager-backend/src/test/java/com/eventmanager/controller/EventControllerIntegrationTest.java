package com.eventmanager.controller;

import com.eventmanager.model.Event;
import com.eventmanager.model.User;
import com.eventmanager.repository.EventRepository;
import com.eventmanager.repository.UserRepository;
import com.eventmanager.security.JwtUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Optional;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@DisplayName("Testes de Integração e Segurança da API - EventController")
class EventControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private EventRepository eventRepo;

    @MockBean
    private UserRepository userRepo;

    @MockBean
    private JwtUtil jwtUtil;

    private User mockUser;
    private Event mockEvent;
    private String validToken;

    @BeforeEach
    void setUp() {
        validToken = "mocked-valid-jwt-token";

        // Criação do usuário mockado para autenticação
        mockUser = new User();
        mockUser.setId(1L);
        mockUser.setName("José Neto");
        mockUser.setEmail("jose@todentro.com");
        mockUser.setPassword("senhaCriptografada");

        // Criação do evento mockado
        mockEvent = new Event();
        mockEvent.setId(99L);
        mockEvent.setName("Aniversário na Savassi");
        mockEvent.setMaxParticipants(10);
        mockEvent.setParticipants(new ArrayList<>());
        mockEvent.setOwner(mockUser);
        mockEvent.setInviteToken("token-valido-123");
    }

    @Test
    @DisplayName("UT-03: Deve bloquear requisições sem Token JWT em endpoints protegidos (Retornar 403)")
    void deveBloquearRotaProtegidaSemToken() throws Exception {
        // Tentando acessar o CRUD de eventos sem passar o Header de Authorization
        mockMvc.perform(get("/api/events")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isForbidden()); // Alterado de isUnauthorized() para isForbidden()
    }

    @Test
    @DisplayName("UT-05: Deve permitir acesso anônimo à consulta por link de convite tokenizado")
    void devePermitirAcessoARotaPublicaDeConvite() throws Exception {
        // Configura o comportamento do mock do repositório
        when(eventRepo.findByInviteToken("token-valido-123")).thenReturn(Optional.of(mockEvent));

        // Rota configurada com permitAll() no SecurityConfig
        mockMvc.perform(get("/api/events/invite/token-valido-123")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(99L))
                .andExpect(jsonPath("$.name").value("Aniversário na Savassi"))
                .andExpect(jsonPath("$.availableSlots").value(10));
    }

    @Test
    @DisplayName("RF-03 / UT-04: Deve alterar o status de pagamento de um participante se autenticado")
    void devePermitirMudarStatusPagamentoComToken() throws Exception {
        // Configura o comportamento do mock de segurança e repositório
        when(jwtUtil.isValid(validToken)).thenReturn(true);
        when(jwtUtil.extractEmail(validToken)).thenReturn("jose@todentro.com");
        when(userRepo.findByEmail("jose@todentro.com")).thenReturn(Optional.of(mockUser));
        when(eventRepo.findByIdAndOwnerId(99L, 1L)).thenReturn(Optional.of(mockEvent));

        // Corpo da requisição simulando a alteração de status
        String requestBody = "{\"paid\": true}";

        mockMvc.perform(put("/api/events/99/participants/1/paid")
                        .header("Authorization", "Bearer " + validToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.ok").value(true));
    }
}