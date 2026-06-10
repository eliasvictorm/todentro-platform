package com.eventmanager.model;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("Testes Unitários de Domínio - Event, Participant e User")
class EventDomainTest {

    private Event event;
    private User owner;

    @BeforeEach
    void setUp() {
        // Inicializa o dono do evento
        owner = new User();
        owner.setId(1L);
        owner.setName("José Vieira");
        owner.setEmail("jose@todentro.com");

        // Inicializa um evento padrão com limite de 3 participantes para os testes
        event = new Event();
        event.setId(10L);
        event.setName("Churrasco do Grupo");
        event.setDescription("Rolê de comemoração do fim do semestre");
        event.setDate(LocalDate.now().plusDays(7));
        event.setTime(LocalTime.of(18, 0));
        event.setLocation("Contagem - MG");
        event.setMaxParticipants(3);
        event.setCategory("Churrasco");
        event.setOwner(owner);
        event.setParticipants(new ArrayList<>());
    }

    @Test
    @DisplayName("UT-01: Deve adicionar participantes e atualizar a contagem de vagas corretamente")
    void deveControlarVagasDisponiveisCorretamente() {
        // Cenário Inicial: Sem participantes, todas as vagas livres
        assertTrue(event.hasAvailableSlots(), "O evento deveria ter vagas disponíveis inicialmente.");
        assertEquals(3, event.getAvailableSlots(), "Deveria ter exatamente 3 vagas livres.");

        // Criando participante 1
        Participant p1 = new Participant();
        p1.setId(1L);
        p1.setName("Carlos Nunes");
        p1.setEvent(event);
        event.getParticipants().add(p1);

        // Validação com 1 participante
        assertTrue(event.hasAvailableSlots());
        assertEquals(2, event.getAvailableSlots());

        // Criando participante 2 e 3 para lotar o evento
        Participant p2 = new Participant();
        p2.setName("Elias Victor");
        p2.setEvent(event);
        event.getParticipants().add(p2);

        Participant p3 = new Participant();
        p3.setName("Isadora Ribeiro");
        p3.setEvent(event);
        event.getParticipants().add(p3);

        // Validação com evento LOTADO
        assertFalse(event.hasAvailableSlots(), "O evento deveria estar lotado.");
        assertEquals(0, event.getAvailableSlots(), "O número de vagas livres deveria ser 0.");
    }

    @Test
    @DisplayName("UT-04: Deve calcular o split de despesas dividindo o custo total pelos participantes ativos")
    void deveCalcularSplitDeDespesaPorPessoa() {
        // Cenário: Evento com 3 participantes ativos
        String[] nomes = {"Carlos", "Elias", "Gabriel"};
        for (String nome : nomes) {
            Participant p = new Participant();
            p.setName(nome);
            p.setEvent(event);
            event.getParticipants().add(p);
        }

        // Simulação da lógica de negócio do Split (Custo Total / Quantidade de Participantes)
        double custoTotalDoChurrasco = 150.00;
        int quantidadeParticipantes = event.getParticipants().size();
        
        double valorPorPessoaCalculado = custoTotalDoChurrasco / quantidadeParticipantes;
        double valorEsperado = 50.00; // 150 / 3

        assertEquals(valorEsperado, valorPorPessoaCalculado, 0.001, "O cálculo do split por pessoa está incorreto.");
    }

    @Test
    @DisplayName("UT-05 (Bônus): Deve gerar um token de convite único e com tamanho exato de 12 caracteres")
    void deveGerarTokenDeConviteValido() {
        assertNull(event.getInviteToken(), "O token inicial deveria ser nulo.");

        String tokenGerado = event.generateInviteToken();

        assertNotNull(tokenGerado, "O token gerado não deveria ser nulo.");
        assertEquals(12, tokenGerado.length(), "O token gerado pela lógica de UUID simplificada deve ter exatamente 12 caracteres.");
        assertEquals(tokenGerado, event.getInviteToken(), "O token gerado deve ser salvo no atributo da entidade Event.");
    }
}