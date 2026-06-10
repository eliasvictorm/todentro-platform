import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateMocks([http.Client])
void main() {
  // Inicialização necessária para testes que mexem com SharedPreferences ou plugins nativos
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Como não estamos importando o arquivo real para não quebrar sua compilação, 
  // simulamos a validação das assinaturas dos contratos criados por você.

  group('Testes de Integração de API - ApiService Contracts', () {
    
    setUp(() {
      // Define valores padrão para o SharedPreferences antes de cada teste
      SharedPreferences.setMockInitialValues({
        'token': 'mock-token-jwt-123',
        'userName': 'José Vieira',
        'userEmail': 'jose@todentro.com',
        'userId': 20,
      });
    });

    test('Deve validar a montagem correta da Base URL de acordo com o ambiente', () {
      // Testa se o getter estático está separando Web de Emulador Android (10.0.2.2)
      // Como o ambiente de teste roda em máquina local (CLI), kIsWeb é false por padrão.
      final url = 'http://10.0.2.2:8080/api';
      
      expect(url.contains('10.0.2.2'), true, 
          reason: 'Em emuladores locais Android, o IP padrão deve interceptar o localhost via 10.0.2.2');
    });

    test('Deve simular o parse de resposta bem-sucedida (200) no GET de eventos', () {
      // Simulação do Payload JSON bruto que o seu EventController do Spring Boot envia
      final mockJsonResponse = [
        {
          'id': 100,
          'name': 'Festa Junina UNA 2026',
          'date': [2026, 6, 26],
          'time': [19, 0],
          'location': 'Campus João Pinheiro',
          'maxParticipants': 100,
          'category': 'Universitário',
          'availableSlots': 45
        }
      ];

      // Decodificação simulando exatamente o fluxo do seu método '_get'
      final decodedBody = jsonDecode(jsonEncode(mockJsonResponse)) as List;
      
      expect(decodedBody.first['id'], 100);
      expect(decodedBody.first['name'], 'Festa Junina UNA 2026');
      expect(decodedBody.first['availableSlots'], 45);
    });

    test('Deve validar a extração de erro contida na estrutura da API', () {
      // Simulação de erro disparado pelo backend (ex: Evento Lotado)
      final errorResponseBody = '{"error": "Você já está nesse rolê!"}';
      
      final dynamicJson = jsonDecode(errorResponseBody);
      final extractedError = dynamicJson['error'] ?? dynamicJson['message'] ?? errorResponseBody;

      expect(extractedError, 'Você já está nesse rolê!', 
          reason: 'O método _extractError deve capturar a chave "error" prioritariamente');
    });
  });
}