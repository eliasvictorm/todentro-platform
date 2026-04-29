package com.eventmanager;

import com.eventmanager.model.Event;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class EventFilterTest {

    private List<Event> todosEventos;

    @BeforeEach
    void setup() {
        todosEventos = new ArrayList<>();
        
        Event e1 = new Event();
        e1.setName("Churrasco da TI");
        e1.setCategory("Social");
        
        Event e2 = new Event();
        e2.setName("Workshop de Java");
        e2.setCategory("Acadêmico");
        
        todosEventos.add(e1);
        todosEventos.add(e2);
    }

    @Test
    void deveFiltrarEventosPorNome() {
        String busca = "Churras";
        List<Event> filtrados = todosEventos.stream()
            .filter(e -> e.getName().toLowerCase().contains(busca.toLowerCase()))
            .collect(Collectors.toList());

        assertEquals(1, filtrados.size());
        assertEquals("Churrasco da TI", filtrados.get(0).getName());
    }

    @Test
    void deveFiltrarEventosPorCategoria() {
        String categoriaSelecionada = "Social";
        List<Event> filtrados = todosEventos.stream()
            .filter(e -> e.getCategory().equals(categoriaSelecionada))
            .collect(Collectors.toList());

        assertEquals(1, filtrados.size());
        assertEquals("Social", filtrados.get(0).getCategory());
    }
}