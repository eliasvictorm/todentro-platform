package com.eventmanager;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import org.junit.jupiter.api.Test;

import com.eventmanager.model.Event;
import com.eventmanager.model.Participant;

public class ParticipantActionTest {

    @Test
    void deveConfirmarParticipanteEAtualizarStatus() {
        Participant p = new Participant();
        
        p.setStatus("Confirmado");

        assertEquals("Confirmado", p.getStatus());
    }

    @Test
    void deveDesabilitarBotaoSeJaEstiverConfirmado() {
        Participant p = new Participant();
        p.setStatus("Confirmado");

        boolean botaoConfirmarDesabilitado = p.getStatus().equals("Confirmado");
        boolean botaoCancelarDesabilitado = p.getStatus().equals("Cancelado");

        assertTrue(botaoConfirmarDesabilitado, "O botão confirmar deveria estar desabilitado");
        assertFalse(botaoCancelarDesabilitado, "O botão cancelar deveria estar habilitado");
    }

    @Test
    void deveRemoverParticipanteDoEventoComSucesso() {

        Event evento = new Event();
        Participant p = new Participant();
        p.setId("p123");
        evento.getParticipants().add(p);
        
        assertEquals(1, evento.getParticipants().size());

        evento.getParticipants().remove(p);

        assertTrue(evento.getParticipants().isEmpty());
        assertEquals(0, evento.getParticipants().size());
    }

    @Test
    void deveCancelarParticipanteEAtualizarStatus() {
        Participant p = new Participant();

        p.setStatus("Cancelado");

        assertEquals("Cancelado", p.getStatus());
        assertTrue(p.getStatus().equals("Cancelado"));
    }
}