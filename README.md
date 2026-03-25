# 🎉 TôDentro - Organizador de Eventos Colaborativo

> Um aplicativo mobile completo para organizar roles em grupo, que centraliza criação de eventos, confirmação de participantes, votações, divisão de gastos e gerenciamento de tarefas.

---

## 📋 Sobre o Projeto

**TÔDentro** resolve o problema da desorganização no planejamento em grupo ao centralizar todas as informações do evento em um único aplicativo. A ferramenta organiza etapas como:

- 📅 Criação e planejamento do evento
- ✅ Confirmação de participantes
- 🗳️ Votações e enquetes
- 💰 Divisão de gastos e pagamentos
- ✓ Tarefas e checklist

Tudo que normalmente fica disperso em conversas, agora está em um único lugar!

---

## 👥 Integrantes do Grupo

| Nome | Matrícula | Email | Curso |
|------|-----------|-------|-------|
| Carlos Nunes | 42320951 | carlitofilho695@gmail.com | Ciência da Computação |
| Elias Victor de Jesus Cardoso Machado | 42415030 | elias.victor.dr@gmail.com | Ciência da Computação |
| Gabriel de Carvalho Andrade | 42521801 | gabrielcarv712@gmail.com | Ciência da Computação |
| Guilherme Ryan Costa Lana | 42412875 | Lanagui333@gmail.com | Ciência da Computação |
| Isadora Ribeiro Eugênio | 42322274 | - | Ciência da Computação |
| José Vieira Lopes Neto | 42413224 | jn038576@gmail.com | Ciência da Computação |

---

## 🏗️ Stack Tecnológico

### **Backend**
- **Java 17+** com **Spring Boot 3.x**
- **Spring Data JPA** para acesso ao banco de dados
- **Spring Security** com JWT para autenticação
- **PostgreSQL** para persistência de dados
- **API REST** com JSON

### **Frontend Mobile**
- **Flutter (Dart)** para multiplataforma (iOS/Android)
- **Provider** ou **Bloc** para gerenciamento de estado
- **HTTP Client** para consumir API

### **Infraestrutura**
- **Git** para versionamento
- **Postman** para testes de API

---

## 🎯 Arquitetura do Projeto

### **Backend (Spring Boot)**
```
backend/
├── src/main/java/com/a3app/
│   ├── controller/          # Endpoints REST
│   │   ├── EventController
│   │   ├── PaymentController
│   │   ├── UserController
│   │   ├── PollController
│   │   └── TaskController
│   ├── service/             # Lógica de negócio
│   │   ├── EventService
│   │   ├── PaymentService
│   │   ├── UserService
│   │   └── NotificationService
│   ├── repository/          # Acesso a dados (Spring Data JPA)
│   │   ├── EventRepository
│   │   ├── PaymentRepository
│   │   ├── UserRepository
│   │   └── TaskRepository
│   ├── entity/              # Modelos de dados
│   │   ├── User
│   │   ├── Event
│   │   ├── Payment
│   │   ├── Poll
│   │   └── Task
│   ├── dto/                 # Data Transfer Objects
│   │   ├── EventDTO
│   │   ├── PaymentDTO
│   │   └── UserDTO
│   ├── security/            # Configuração JWT e Security
│   ├── config/              # Configurações gerais (CORS, etc)
│   └── A3AppApplication.java
├── pom.xml
└── application.properties
```

### **Frontend (Flutter)**
```
flutter_app/
├── lib/
│   ├── screens/             # Telas do app
│   │   ├── login_screen.dart
│   │   ├── home_screen.dart
│   │   ├── event_screen.dart
│   │   ├── create_event_screen.dart
│   │   ├── payment_screen.dart
│   │   ├── poll_screen.dart
│   │   └── task_screen.dart
│   ├── models/              # Estruturas de dados
│   │   ├── user_model.dart
│   │   ├── event_model.dart
│   │   ├── payment_model.dart
│   │   └── task_model.dart
│   ├── services/            # Requisições HTTP
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   ├── event_service.dart
│   │   └── payment_service.dart
│   ├── widgets/             # Componentes reutilizáveis
│   │   ├── app_drawer.dart
│   │   ├── event_card.dart
│   │   └── payment_card.dart
│   ├── providers/           # Gerenciamento de estado
│   │   ├── user_provider.dart
│   │   ├── event_provider.dart
│   │   └── payment_provider.dart
│   └── main.dart
├── pubspec.yaml
└── pubspec.lock
```

---

## 👤 Papéis de Usuário

### **Organizador**
- Criar, editar e excluir eventos
- Gerenciar participantes e co-organizadores
- Acompanhar inscrições e confirmações
- Delegar permissões administrativas

### **Co-Organizador**
- Auxiliar na gestão do evento
- Atualizar informações
- Gerenciar participantes
- Suporte entre organizadores

### **Participante**
- Visualizar eventos disponíveis
- Confirmar presença
- Acompanhar detalhes do evento
- Receber notificações

### **Convidado**
- Visualizar informações do evento convidado
- Confirmar ou recusar participação
- Acesso restrito às informações

---

## 📱 Telas Planejadas

1. **Tela de Login e Cadastro** - Autenticação de usuários
2. **Tela Inicial** - Dashboard com grupos e eventos
3. **Tela de Criação de Evento** - Formulário de eventos
4. **Tela de Feed do Evento** - Data, local, participantes e postagens
5. **Tela de Enquetes e Votações** - Decisões colaborativas
6. **Tela de Divisão de Gastos** - Cálculo e pagamentos
7. **Tela de Tarefas** - Checklist e organização

---

## 🔧 Como Começar

### **Pré-requisitos**
- Java 17 ou superior
- Maven
- Docker (opcional)
- Flutter SDK
- Git

### **Setup do Backend**
```bash
# Clonar repositório
git clone <repo-url>
cd backend

# Instalar dependências
mvn clean install

# Executar aplicação (desenvolvimento)
mvn spring-boot:run
```

### **Setup do Frontend**
```bash
# Ir para pasta do Flutter
cd flutter_app

# Instalar dependências
flutter pub get

# Rodar no emulador/dispositivo
flutter run
```

---

## 🚀 Funcionalidades Principais

✅ Autenticação segura com JWT  
✅ Criação e gerenciamento de eventos  
✅ Sistema de confirmação de participantes  
✅ Votações e enquetes colaborativas  
✅ Divisão automática de gastos  
✅ Histórico de pagamentos  
✅ Gerenciamento de tarefas  
✅ Notificações em tempo real  
✅ Controle de permissões por papel  

---

## 📄 Licença

Este projeto é parte da disciplina de **Gestão e Qualidade de Software** da Universidade UNA.

---

## 📞 Suporte

Para dúvidas ou sugestões, abra uma issue no repositório ou entre em contato com qualquer membro do grupo.
