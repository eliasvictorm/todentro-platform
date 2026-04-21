package com.eventmanager;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import static org.junit.jupiter.api.Assertions.assertEquals;
import org.junit.jupiter.api.Test;

import com.eventmanager.model.Event;

public class EventFilterTest {

    @Test
    void deveFiltrarEventosPorNome() {
        List<Event> todosEventos = new ArrayList<>();
        
        Event e1 = new Event();
        e1.setName("Churrasco");
        
        Event e2 = new Event();
        e2.setName("Reunião de Trabalho");
        
        todosEventos.add(e1);
        todosEventos.add(e2);

        String busca = "Churras";
        List<Event> filtrados = todosEventos.stream()
            .filter(e -> e.getName().toLowerCase().contains(busca.toLowerCase()))
            .collect(Collectors.toList());

        assertEquals(1, filtrados.size());
        assertEquals("Churrasco", filtrados.get(0).getName());
    }

    @Test
    void deveFiltrarEventosPorCategoria() {
        List<Event> todosEventos = new ArrayList<>();
        
        Event e1 = new Event();
        e1.setName("Festa");
        e1.setCategory("Social");
        
        Event e2 = new Event();
        e2.setName("Workshop");
        e2.setCategory("Acadêmico");
        
        todosEventos.add(e1);
        todosEventos.add(e2);


        String categoriaSelecionada = "Social";
        List<Event> filtrados = todosEventos.stream()
            .filter(e -> e.getCategory().equals(categoriaSelecionada))
            .collect(Collectors.toList());

        assertEquals(1, filtrados.size());
        assertEquals("Social", filtrados.get(0).getCategory());
    }

    @Test
    void deveLimparFiltrosERetornarListaCompleta() {

        String search = "Nome Inexistente";
        List<Event> todosEventos = new ArrayList<>();
        todosEventos.add(new Event());
        
        search = "";
        String finalSearch = search;
        
        List<Event> filtrados = todosEventos.stream()
            .filter(e -> e.getName() == null || e.getName().contains(finalSearch))
            .collect(Collectors.toList());

        assertEquals(todosEventos.size(), filtrados.size());
    }
}
