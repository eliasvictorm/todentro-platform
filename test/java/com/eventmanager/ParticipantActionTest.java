package com.eventmanager;

import com.eventmanager.model.Event;
import com.eventmanager.model.Participant;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class ParticipantActionTest {

    @Test
    void deveAdicionarERemoverParticipanteDoEvento() {
        Event evento = new Event();
        Participant p = new Participant();
        p.setId(1L);
        
        evento.getParticipants().add(p);
        assertEquals(1, evento.getParticipants().size());
    
        evento.getParticipants().remove(p);
        assertTrue(evento.getParticipants().isEmpty());
    }

    @Test
    void deveControlarLotacaoDoEvento() {
        Event evento = new Event();
        evento.setMaxParticipants(1);
        
        Participant p1 = new Participant();
        evento.getParticipants().add(p1);

        assertFalse(evento.hasAvailableSlots(), "O evento deveria estar lotado");
        assertEquals(0, evento.getAvailableSlots());
    }
}