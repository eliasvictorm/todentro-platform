import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importe os caminhos corretos de acordo com a estrutura do seu projeto:
import 'package:todentro/models/models.dart';
import 'package:todentro/providers/providers.dart';

// Mock temporário para simular as respostas de sucesso dos modelos e providers
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UT-02: Testes Unitários de Modelos (Mapeamento JSON)', () {
    test('Deve mapear JSON de AppUser corretamente para o objeto Dart', () {
      final jsonResponse = {
        'id': 20,
        'name': 'José Vieira Lopes Neto',
        'email': 'jose@todentro.com',
        'avatarUrl': 'https://link.com/foto.png'
      };

      final user = AppUser.fromJson(jsonResponse);

      expect(user.id, 20);
      expect(user.name, 'José Vieira Lopes Neto');
      expect(user.email, 'jose@todentro.com');
      expect(user.avatarUrl, 'https://link.com/foto.png');
    });

    test('Deve tratar formato de lista do Spring Boot para data e hora no Event.fromJson', () {
      final jsonResponse = {
        'id': 1,
        'name': 'Churrasco de Fim de Semestre',
        'date': [2026, 6, 26], // Formato retornado pelo Jackson do Spring Boot
        'time': [14, 30],
        'location': 'Contagem, MG',
        'maxParticipants': 15,
        'category': 'Churrasco',
        'participantCount': 5,
        'availableSlots': 10
      };

      final event = Event.fromJson(jsonResponse);

      expect(event.date, '2026-06-26');
      expect(event.time, '14:30');
      expect(event.availableSlots, 10);
      expect(event.hasAvailableSlots(), true);
    });

    test('Deve aplicar valores padrão (Fallback) se chaves essenciais vierem nulas do JSON', () {
      final jsonResponse = {
        'id': 2,
        'date': '2026-07-20',
        'time': '18:00',
        // 'name' e 'category' ausentes no payload
      };

      final event = Event.fromJson(jsonResponse);

      expect(event.name, '', reason: 'Se o nome vier nulo, deve falhar para string vazia');
      expect(event.category, 'Outro', reason: 'Se a categoria vier nula, deve assumir "Outro"');
    });
  });

  group('Testes de Gerenciamento de Estado (Providers)', () {
    test('AuthProvider deve iniciar com estado deslogado', () {
      final authProvider = AuthProvider();

      expect(authProvider.isLoggedIn, false);
      expect(authProvider.userName, '');
      expect(authProvider.userEmail, '');
    });

    test('EventProvider deve iniciar com lista vazia e sem carregamento', () {
      final eventProvider = EventProvider();

      expect(eventProvider.events.isEmpty, true);
      expect(eventProvider.loading, false);
      expect(eventProvider.error, null);
    });
  });
}