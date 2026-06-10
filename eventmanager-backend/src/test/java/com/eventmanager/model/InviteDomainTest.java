package com.eventmanager.model;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("Testes Unitários de Domínio - Ciclo de Vida do Invite")
class InviteDomainTest {

    private Event mockEvent;
    private User inviter;
    private User invitee;
    private Invite invite;

    @BeforeEach
    void setUp() {
        // Instancia os envolvidos no fluxo de convite
        inviter = new User();
        inviter.setId(1L);
        inviter.setName("José Neto");

        invitee = new User();
        invitee.setId(2L);
        invitee.setName("Elias Victor");
        invitee.setEmail("elias@todentro.com");

        mockEvent = new Event();
        mockEvent.setId(100L);
        mockEvent.setName("Social do Final de Semana");

        // Inicializa o convite padrão
        invite = new Invite();
        invite.setId(5L);
        invite.setEvent(mockEvent);
        invite.setInviter(inviter);
    }

    @Test
    @DisplayName("Deve inicializar um convite com status PENDING e data de criação atual")
    void deveInicializarComStatusPendente() {
        // Valida o estado inicial padrão definido na sua entidade
        assertEquals(Invite.Status.PENDING, invite.getStatus(), "O status inicial do convite deve ser PENDING.");
        assertNotNull(invite.getCreatedAt(), "A data de criação 'createdAt' não deve ser nula.");
        assertTrue(invite.getCreatedAt().isBefore(LocalDateTime.now().plusSeconds(1)), "A data de criação deve ser o momento atual.");
    }

    @Test
    @DisplayName("Deve permitir a alteração correta de status para ACCEPTED e DECLINED")
    void deveTransicionarStatusCorretamente() {
        // Configurando o convidado direto (busca por e-mail ou usuário interno)
        invite.setInvitee(invitee);
        invite.setInviteeEmail(invitee.getEmail());

        // Fluxo 1: Usuário aceita o convite
        invite.setStatus(Invite.Status.ACCEPTED);
        assertEquals(Invite.Status.ACCEPTED, invite.getStatus(), "O status deveria ter mudado para ACCEPTED.");

        // Fluxo 2: Usuário recusa o convite
        invite.setStatus(Invite.Status.DECLINED);
        assertEquals(Invite.Status.DECLINED, invite.getStatus(), "O status deveria ter mudado para DECLINED.");
    }

    @Test
    @DisplayName("Deve validar a integridade dos dados de quem convida e quem recebe")
    void deveGarantirVinculoDosUsuariosNoConvite() {
        invite.setInviteeEmail("externo@provedor.com");

        // Verifica se a lógica aceita convites para e-mails que ainda não possuem conta (invitee nulo)
        assertNull(invite.getInvitee(), "O usuário convidado pode ser nulo se for um convite por e-mail externo.");
        assertEquals("externo@provedor.com", invite.getInviteeEmail());
        assertEquals(1L, invite.getInviter().getId(), "O ID do organizador que enviou o convite deve ser mantido.");
    }
}